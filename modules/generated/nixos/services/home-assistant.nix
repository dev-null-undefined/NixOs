{
  config,
  pkgs,
  self,
  ...
}: let
  dataDir = "/var/lib/hass";
  haData = ./_home-assistant-data;
in {
  sops.secrets."home-assistant-google-sa" = {
    sopsFile = self.outPath + "/secrets/home-assistant-google-sa.json";
    format = "binary";
    owner = "hass";
    path = "${dataDir}/SERVICE_ACCOUNT.json";
  };

  services.home-assistant = {
    enable = true;
    configDir = dataDir;

    extraComponents = [
      "default_config"
      "frontend"
      "http"
      "automation"
      "script"
      "scene"
      "bluetooth"
      "zha"
      "shelly"
      "esphome"
      "oralb"
      "google_assistant"
      "mobile_app"
      "unifi"
      "smartthings"
      "withings"
      "met"
      "sun"
      "radio_browser"
      "shopping_list"
      "go2rtc"
      "generic_thermostat"
      "ibeacon"
      "mcp_server"
      "google_translate"
      "group"
      "backup"
      "dhcp"
    ];

    config = {
      default_config = {};
      frontend = {};

      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1/32"
          "10.100.0.0/24"
        ];
      };

      zha = {
        enable_quirks = true;
        custom_quirks_path = "${dataDir}/zha_quirks/";
      };

      google_assistant = {
        project_id = "domov-home-assistant";
        # The renderYAMLFile post-processor in the nixpkgs module unquotes
        # any string starting with `!` so this becomes a literal YAML tag.
        service_account = "!include SERVICE_ACCOUNT.json";
        report_state = true;
        expose_by_default = true;
      };

      automation = builtins.fromJSON (builtins.readFile (haData + "/automations.json"));
      script = builtins.fromJSON (builtins.readFile (haData + "/scripts.json"));
      scene = builtins.fromJSON (builtins.readFile (haData + "/scenes.json"));
    };
  };
}
