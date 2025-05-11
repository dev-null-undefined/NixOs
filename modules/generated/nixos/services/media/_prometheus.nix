{
  # Enable Prometheus exporters
  systemd.services =
    lib.mapAttrs' (name: attrs: {
      name = "prometheus-${name}-exporter";
      value = {
        description = "Export Prometheus metrics for ${name}";
        after = ["network.target"];
        wantedBy = ["${name}.service"];
        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          ExecStart = let
            # Sabnzbd doesn't accept the URI path, unlike the others
            url =
              if name != "sabnzbd"
              then "http://${attrs.url}/${name}"
              else "http://${attrs.url}";
            # Exportarr is trained to pull from the arr services
          in ''
            ${pkgs.exportarr}/bin/exportarr ${name} \
                        --url ${url} \
                        --port ${attrs.exportarrPort}'';
          EnvironmentFile =
            lib.mkIf (builtins.hasAttr "apiKey" attrs) attrs.apiKey;
          Restart = "on-failure";
          ProtectHome = true;
          ProtectSystem = "strict";
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHostname = true;
          ProtectClock = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          NoNewPrivileges = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RemoveIPC = true;
          PrivateMounts = true;
        };
      };
    })
    arrConfig;

  # Prometheus scrape targets (expose Exportarr to Prometheus)
  nmasur.presets.services.prometheus-exporters.scrapeTargets = map (key: "127.0.0.1:${
    lib.attrsets.getAttrFromPath [key "exportarrPort"] arrConfig
  }") (builtins.attrNames arrConfig);
}
