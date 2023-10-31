{
  lib,
  config,
  pkgs,
  ...
}: let
  uniqueListPred = list: pred:
    builtins.foldl' (acc: current: let
      index = lib.lists.findFirstIndex (pred current) (-1) acc;
      alreadyIn = index != -1;
    in
      acc ++ (lib.lists.optional (!alreadyIn) current)) []
    list;

  hasDuplicates = list: pred: let
    uniques = uniqueListPred list pred;
  in
    (builtins.length uniques) != (builtins.length list);

  pow = base: exponent:
    if exponent > 0
    then let
      and1 = x: (x / 2) * 2 != x;
      x = pow base (exponent / 2);
    in
      x
      * x
      * (
        if and1 exponent
        then base
        else 1
      )
    else if exponent == 0
    then 1
    else throw "undefined";

  # TODO test
  parseIp = ip: let
    splitRemoveEmpty = delim: string: builtins.filter builtins.isString (builtins.split delim string);

    prefix = builtins.elemAt (splitRemoveEmpty "/" ip) 1;
    prefixLenght = lib.strings.toInt prefix;
    ipOnly = builtins.head (splitRemoveEmpty "/" ip);
    ipParts = builtins.map lib.strings.toInt (splitRemoveEmpty "\\." ipOnly);

    bitsToMask = bits: builtins.foldl' (acc: current: builtins.bitOr acc (pow 2 (7 - current))) 0 (lib.lists.range 0 (bits - 1)); # TODO

    indexToMask = index:
      bitsToMask
      (lib.trivial.min 8
        (lib.trivial.max 0
          (prefixLenght - (8 * index))));

    netmaskParts = builtins.map indexToMask (lib.lists.range 0 3);

    networkParts = builtins.map (
      index:
        builtins.bitAnd
        (builtins.elemAt ipParts index)
        (builtins.elemAt netmaskParts index)
    ) (lib.lists.range 0 3);

    network = builtins.concatStringsSep "." (builtins.map builtins.toString networkParts);
    netmask = builtins.concatStringsSep "." (builtins.map builtins.toString netmaskParts);
  in {
    ip = ipOnly;
    ipWithPrefix = ip;
    inherit network netmask;
    networkWithPrefix = network + "/" + prefix;
  };

  allConfigs = config.custom.wireguard.allConfigs;
  hostIps = config.custom.wireguard.ips;

  hostConfigs = builtins.filter (config: builtins.any (hostIp: hostIp == config.ip) hostIps) allConfigs;

  hostServerConfigs = builtins.filter (config: config.isServer) hostConfigs;
  isServer = (builtins.length hostServerConfigs) != 0;

  isEnabled = (builtins.length hostIps) != 0;

  serverConfig = {
    # enable NAT
    enable = true;
    internalInterfaces = builtins.map (config: config.interfaceName) hostServerConfigs;
  };

  relevantPeersConfigs = config: let
    parsedIp = parseIp config.ip;
  in
    builtins.filter (other: let
      otherParsedIp = parseIp other.ip;
    in
      parsedIp.network == otherParsedIp.network && config.ip != other.ip)
    allConfigs;

  genPeers = config: let
    peersConfs = relevantPeersConfigs config;
  in
    builtins.map (peer: let
      parsedIp = parseIp peer.ip;
    in
      {
        inherit (peer) publicKey name;
        allowedIPs =
          if peer.isServer
          then
            (
              if config.forwardAll && peer.forwardAll && peer.isServer
              then ["0.0.0.0/0"]
              else ["${parsedIp.networkWithPrefix}"]
            )
          else
            (
              if config.isServer
              then ["${parsedIp.ip}/32"]
              else []
            );
        persistentKeepalive = 25;
      }
      // (
        lib.attrsets.optionalAttrs peer.isServer {
          endpoint = "${peer.endpoint}:51820";
        }
      ))
    peersConfs;
in {
  config = lib.mkIf isEnabled {
    networking = {
      firewall = {
        # Clients and peers can use the same port, see listenport
        allowedUDPPorts = [51820];
      };
      nat = lib.attrsets.optionalAttrs isServer serverConfig;

      wireguard.interfaces = builtins.foldl' (acc: interfaceConfig: let
        parsedIp = parseIp interfaceConfig.ip;
      in
        acc
        // {
          "${interfaceConfig.interfaceName}" =
            {
              ips = [interfaceConfig.ip];

              # to match firewall allowedUDPPorts (without this wg uses random port numbers)
              listenPort = 51820;

              privateKeyFile = "/wireguard-keys/private-${interfaceConfig.interfaceName}";
              generatePrivateKeyFile = true;

              peers = genPeers interfaceConfig;
            }
            // (
              lib.attrsets.optionalAttrs interfaceConfig.isServer {
                # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
                # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
                postSetup = ''
                  ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${parsedIp.networkWithPrefix} -o ${config.networking.nat.externalInterface} -j MASQUERADE
                '';

                # This undoes the above command
                postShutdown = ''
                  ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${parsedIp.networkWithPrefix} -o ${config.networking.nat.externalInterface} -j MASQUERADE
                '';
              }
            );
        }) {}
      hostConfigs;
    };

    assertions = [
      {
        assertion = !(builtins.any (config: config.isServer && (builtins.isNull config.endpoint)) allConfigs);
        message = "server peer must have endpoint option set";
      }
      {
        assertion = !(builtins.any (config: (!config.isServer) && (!(builtins.isNull config.endpoint))) allConfigs);
        message = "client peers must have endpoint set to null";
      }
      {
        assertion = (builtins.length hostConfigs) == (builtins.length hostIps);
        message = "each IP must have corresponding peer config in the allConfigs";
      }
      {
        assertion =
          (builtins.length (builtins.filter (
            peer: peer.allowedIPs == ["0.0.0.0/0"]
          ) (builtins.concatMap genPeers hostConfigs)))
          <= 1;
        message = "there should be at most one VPN like connection with forwardAll set";
      }
      {
        assertion = !(hasDuplicates allConfigs (a: b: a.ip == b.ip));
        message = "multiple configs with the same IP";
      }
      {
        assertion = (!isServer) || (!(builtins.isNull config.networking.nat.externalInterface));
        message = "external NAT interface must be set manualy";
      }
      {
        assertion =
          !(hasDuplicates hostIps (a: b: let
            aParsed = parseIp a;
            bParsed = parseIp b;
          in
            aParsed.networkWithPrefix == bParsed.networkWithPrefix));
        message = "host should have only one IP from the same network";
      }
    ];
  };

  options.custom.wireguard = let
    configOptions = self: {
      options = {
        ip = lib.mkOption {
          type = lib.types.str;
          description = lib.mdDoc "The IP address of the wireguard interface.";
        };
        interfaceName = lib.mkOption {
          default = "wg0"; # TODO generate interface name based on all the unique networks
          type = lib.types.str;
          description = lib.mdDoc "Interface name";
        };
        forwardAll = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = lib.mdDoc "Forward all trafic through the server must be set on the server and the client as well!!.";
        };
        isServer = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = lib.mdDoc "Is server."; # TODO better docs
        };
        endpoint = lib.mkOption {
          default = null;
          type = lib.types.nullOr lib.types.str;
          description = lib.mdDoc "Public IP for servers only.";
        };
        publicKey = lib.mkOption {
          type = lib.types.singleLineStr;
          description = lib.mdDoc "Public key of the peer";
        };
        name = lib.mkOption {
          default =
            builtins.replaceStrings
            ["/" "-" " " "+" "="]
            ["-" "\\x2d" "\\x20" "\\x2b" "\\x3d"]
            self.config.publicKey;
          defaultText = lib.options.literalExpression "publicKey";
          type = lib.types.str;
          description = lib.mdDoc "Optional name of the peer used for unit name";
        };
      };
    };
  in {
    allConfigs = lib.mkOption {
      default = [];
      type = with lib.types; listOf (submodule configOptions);
      description = lib.mdDoc ''
        List of all configs across all the host.
        Should be defined in the special folder hosts/shared,
        as it is used to chose which peer to allow.
      '';
    };
    ips = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
      description = lib.mdDoc ''
        List of IPs that should be enabled on this device
        Each IP must have matching config in the configs option with all details specified.
        This will also automatically connect to all the peers and servers that are in the same subnet.
      '';
    };
  };
}
