{
  pkgs,
  utils,
  config,
  ...
}: let
  settings = {
    filebeat.inputs = [
      {
        type = "log";
        paths = ["/var/log/nginx/access.log"];
        fields_under_root = true;
        json = {
          keys_under_root = true;
          add_error_key = true;
        };
        fields = {
          service = {
            type = "nginx";
            inherit (config.services.nginx.package) version name;
          };
        };
      }
    ];

    output.logstash.hosts = ["127.0.0.1:5044"];
  };
in {
  systemd.services.filebeat = {
    description = "Filebeat log shipper";
    wantedBy = ["multi-user.target"];
    wants = ["elasticsearch.service"];
    after = ["elasticsearch.service"];
    serviceConfig = {
      ExecStartPre = pkgs.writeShellScript "filebeat-exec-pre" ''
        set -euo pipefail

        umask u=rwx,g=,o=

        ${utils.genJqSecretsReplacementSnippet settings
          "/var/lib/filebeat/filebeat.yml"}
      '';
      ExecStart = ''
        ${pkgs.filebeat}/bin/filebeat -e \
          -c "/var/lib/filebeat/filebeat.yml" \
          --path.data "/var/lib/filebeat"
      '';
      Restart = "always";
      StateDirectory = "filebeat";
    };
  };

  services = {
    logstash = {
      enable = true;
      inputConfig = ''
        beats {
          port => 5044
        }
      '';
      filterConfig = ''
        geoip {
          target => "geoip"
          source => "client_ip"
          add_field => [ "[geoip][coordinates]", "%{[geoip][longitude]}" ]
          add_field => [ "[geoip][coordinates]", "%{[geoip][latitude]}" ]
        }

        mutate {
          convert => [ "size", "integer" ]
          convert => [ "status", "integer" ]
          convert => [ "responsetime", "float" ]
          convert => [ "upstreamtime", "float" ]
          convert => [ "[geoip][coordinates]", "float" ]
          remove_field => [ "ecs","agent","host","cloud","@version","input","logs_type" ]
        }

        useragent {
          source => "http_user_agent"
          target => "ua"
        }
      '';
      outputConfig = ''
        elasticsearch {
            index => "logstash-nginx-sysadmins-%{+YYYY.MM.dd}"
        }
      '';
    };
  };
}
