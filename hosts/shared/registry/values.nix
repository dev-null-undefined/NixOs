{
  registry = {
    domain = "dev-null.me";
    tailnetDomain = "rat-python.ts.net";

    hosts = {
      homie = {
        lanIp = "192.168.2.1";
        wgIp = "10.100.0.4";
        tailscaleIp = "100.103.242.75";
      };
      homie-vpn = {
        lanIp = "10.200.200.2";
      };
      oracle-server = {
        wgIp = "10.100.0.1";
        tailscaleIp = "100.105.178.96";
      };
      brnikov = {
        wgIp = "10.100.0.2";
        tailscaleIp = "100.69.94.56";
      };
      prosek-wagner = {
        tailscaleIp = "100.107.165.74";
      };
      honey = {
        tailscaleIp = "100.83.239.55";
      };
      idk = {
        wgIp = "10.100.0.3";
      };
      xps = {
        wgIp = "10.100.0.5";
        tailscaleIp = "100.84.21.87";
      };
      x1 = {
        tailscaleIp = "100.111.56.12";
      };
    };

    services = {
      # User-facing services
      grafana = {
        host = "homie";
        port = 3000;
        subdomain = "grafana";
      };
      jellyfin = {
        host = "homie";
        port = 8096;
        subdomain = "jellyfin";
      };
      jellyseerr = {
        host = "homie";
        port = 5055;
        subdomain = "jellyseerr";
      };
      sonarr = {
        host = "homie";
        port = 8989;
        subdomain = "sonarr";
      };
      radarr = {
        host = "homie";
        port = 7878;
        subdomain = "radarr";
      };
      prowlarr = {
        host = "homie";
        port = 9696;
        subdomain = "prowlarr";
      };
      bazarr = {
        host = "homie";
        port = 6767;
        subdomain = "bazarr";
      };
      transmission = {
        host = "homie-vpn";
        port = 9091;
        subdomain = "transmission";
      };
      nextcloud = {
        host = "homie";
        port = 443;
        subdomain = "cloud";
      };
      unifi = {
        host = "homie";
        port = 8443;
        subdomain = "unifi";
      };
      crafty = {
        host = "homie";
        port = 8100;
        subdomain = "mc";
      };
      minecraft = {
        host = "homie";
        port = 25565;
      };

      # Home Assistant instances
      home-assistant = {
        host = "homie";
        port = 8123;
        subdomain = "home";
      };
      home-assistant-brnikov = {
        host = "brnikov";
        port = 8123;
        subdomain = "brnikov";
      };
      home-assistant-prosek = {
        host = "prosek-wagner";
        port = 8123;
        subdomain = "prosek";
      };

      # Infrastructure
      adguard = {
        host = "homie";
        port = 3380;
      };
      adguard-dns = {
        host = "homie";
        port = 53;
      };
      prometheus = {
        host = "homie";
        port = 9001;
      };
      victorialogs = {
        host = "homie";
        port = 9428;
      };
      ntopng = {
        host = "homie";
        port = 3001;
      };
      influxdb2 = {
        host = "homie";
        port = 8086;
      };
      harmonia = {
        host = "homie";
        port = 5000;
        internalPort = 5001;
      };
      atuin = {
        host = "homie";
        port = 8888;
        subdomain = "atuin";
      };
      minecraft-voice = {
        host = "homie";
        port = 33665;
      };

      # Prometheus exporters
      adguard-exporter = {
        host = "homie";
        port = 9712;
      };
      jellyfin-exporter = {
        host = "homie";
        port = 9711;
      };
      sonarr-exporter = {
        host = "homie";
        port = 9709;
      };
      radarr-exporter = {
        host = "homie";
        port = 9710;
      };
      node-exporter-oracle = {
        host = "oracle-server";
        port = 9100;
      };
      node-exporter-prosek = {
        host = "prosek-wagner";
        port = 9100;
      };
      node-exporter-brnikov = {
        host = "brnikov";
        port = 9100;
      };
    };

    values.sshKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAG7FcqMB3VmekSsunDI1LWdiMJrItK25Y0klffjjsd5G50Xakbd2L/zdSLLlz+UtWD/CbgZXdO399gjXPVadNoboXOiELbEhzDZqOWZ4TA9ZWzsn+JRNIgZViLqNmFNFLsesAElRFjzNryEcjwUcB1yUyMMu4WdBrVBCeqomCRNY94NvBx/8xxjg0Huldyf+VBZMx2J8rmghEjxCQs573mmLibc62XmTYlvg7RGjgdJPRPyY7VvcB0X8SbzIHocVV6cGW6iyZi8WzeXAZMpH7euFeeTP2eTFBBmaWzbh71Ep9WBGDrG6fnZXokipBlVHl9i+TWEAJtW9171COAXAPOJEm74WQrrpin0VFFLa0iNT1eFjPCsz67Ll2ykO6hAcH4KpXWXlMT1R5BgIQE1QwqA++g7npq18D0iWWr/BKP4q7YQgyapseU6Vzpp8i/GX2o7+qeuxgus2Kk49yZStxHtDs4aNJ1EMtkRqq83YiCiYvTUq18doRidfsX42g32GnA4a0yAXOvg/5IDln9Y7iVwjylVQagJjy3TcWYaPqdbTnpTp7GUNK3XOccsqZZrvwNGbe6LXjCoLWaooaQXw4dE1AoUooo9J9GDIAK0AAuXWmzGcrj+V7dULdiG9hPVpabN29/aJUpxlkP0khGhaoX8Of+NDLFgmWWy8NXCPinw== cardno:19 716 313"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDy3QrJeu3E0ai/Jx7jAZTUlFef9EG+TXqhALpl1rkb/eIZpcGjg4WqAIQ9OmmCdc7IC4SDg6zamK8yDdnRVaEX3ISk5PbALmWtc5F/AjbvylcKmMMG15GiX7W5nj1V4HAmRXN/iKZjtoHec5rxa3A4E6EH6OC8WtlnDCFpWtUxRZcT9Vx2cgpYvUA1rYyfWQQFO29wPeQY26yYiYp37jNLMgdg5tb5nym0Q5NBDwMb84hav8Lz0EhCwTHgE/vRru0Im+mmSVoIJvi+Q68+JIVwu8FzuZCrBIRdO7KqDB/Vwzo0ZZR8bKoUcy77QYI9YeNyarPVTon3xLZXqu1ENeuZnvCbJkr8OKQoQxMUkACvKpu9vyQXamLLkbnv7ZgjsrEC7kHJji4avVgv0WZmcjvzb1YZPq/bhZIPgDaI7DlnkZ0GBX/HWNHhfHT/uCcsFeMcUVaoJo6agMPRZY6PxAVW97zj4ZctmfTts+Zra4zgSrV/5ZdMfaLfVHuxYE51PnYnASqcjTGBdicAdgHiohc5BHbUa+0eJlBM1mCbZvDmQhrKpfrK/lRqBw7kwxr1lgf8JkPajvbqAj4vpkD3uYBBGUXziyYsXiB28DtHWlNQDo+5+dzZTX1wTEWSZoTp2fr3s/RU0BLJhzcOy344ywyiJm17Nub3GYjE8LgZrTJpWQ== openpgp:0xC23BC2B3"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/lPlb+q+FMf1o/oQg4S+9xscvXoB1zUSmoZUA4MFQt martin@x1"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKp+3o03aaozSpWfjP+/ivQQxKpanR242QL5vadF9kN2 martin@honey"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH60p2f6pQ92kILoLI962PLZcFiTgNb/TxU7vs6rkzoR marti@bee"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBUNcxn0s/dQ7ZPNQVWKyNwHkxIlpbqUiVleIcco5Ar martin@xps"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdscJaL7en73oIt2qvjE9rMIYCzXHTNdN3mOfmHiBsF martin.kos@Martins-MacBook-Air.local"
    ];
  };
}
