{
  config,
  pkgs,
  self,
  ...
}: let
  dataDir = "/var/lib/hass";
  haData = ./_home-assistant-data;

  # Bedroom light transitions, in seconds. Set to 0 during testing so each
  # tier change snaps instantly; restore to ~2 / ~5 for normal "feel".
  fadeIn = 2;
  fadeOut = 5;
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
      script =
        (builtins.fromJSON (builtins.readFile (haData + "/scripts.json")))
        // {
          # Apply the bedroom light tier currently held in
          # input_number.bedroom_light_level (0–10).
          # Mapping per light is a Jinja array indexed by the level.
          apply_bedroom_level = {
            alias = "Apply Bedroom Light Level";
            mode = "restart";
            sequence = [
              {variables.L = "{{ states('input_number.bedroom_light_level') | int(0) }}";}
              # Portable Lamp — ramps first, stays warm
              {
                choose = [
                  {
                    conditions = [
                      {
                        condition = "template";
                        value_template = "{{ L > 0 }}";
                      }
                    ];
                    sequence = [
                      {
                        service = "light.turn_on";
                        target.entity_id = "light.prenosna_svetluska_light";
                        data = {
                          brightness_pct = "{{ [0, 10, 25, 50, 100, 100, 100, 100, 100, 100, 100][L] }}";
                          color_temp_kelvin = "{{ [2700, 2000, 2200, 2400, 2700, 2700, 2700, 2700, 2700, 3000, 3500][L] }}";
                          transition = fadeIn;
                        };
                      }
                    ];
                  }
                ];
                default = [
                  {
                    service = "light.turn_off";
                    target.entity_id = "light.prenosna_svetluska_light";
                    data.transition = fadeOut;
                  }
                ];
              }
              # Ceiling — joins at L=5
              {
                choose = [
                  {
                    conditions = [
                      {
                        condition = "template";
                        value_template = "{{ L >= 5 }}";
                      }
                    ];
                    sequence = [
                      {
                        service = "light.turn_on";
                        target.entity_id = "light.philips_915005998001_light";
                        data = {
                          brightness_pct = "{{ [0, 0, 0, 0, 0, 20, 50, 80, 100, 100, 100][L] }}";
                          color_temp_kelvin = "{{ [2700, 2700, 2700, 2700, 2700, 2700, 3000, 3200, 3500, 3800, 4000][L] }}";
                          transition = fadeIn;
                        };
                      }
                    ];
                  }
                ];
                default = [
                  {
                    service = "light.turn_off";
                    target.entity_id = "light.philips_915005998001_light";
                    data.transition = fadeOut;
                  }
                ];
              }
              # Top Right Monitor — joins at L=7
              {
                choose = [
                  {
                    conditions = [
                      {
                        condition = "template";
                        value_template = "{{ L >= 7 }}";
                      }
                    ];
                    sequence = [
                      {
                        service = "light.turn_on";
                        target.entity_id = "light.signify_netherlands_b_v_440400982842_light_2";
                        data = {
                          brightness_pct = "{{ [0, 0, 0, 0, 0, 0, 0, 30, 60, 80, 100][L] }}";
                          color_temp_kelvin = "{{ [3500, 3500, 3500, 3500, 3500, 3500, 3500, 3500, 3500, 4000, 4000][L] }}";
                          transition = fadeIn;
                        };
                      }
                    ];
                  }
                ];
                default = [
                  {
                    service = "light.turn_off";
                    target.entity_id = "light.signify_netherlands_b_v_440400982842_light_2";
                    data.transition = fadeOut;
                  }
                ];
              }
              # Left Monitor — joins at L=7
              {
                choose = [
                  {
                    conditions = [
                      {
                        condition = "template";
                        value_template = "{{ L >= 7 }}";
                      }
                    ];
                    sequence = [
                      {
                        service = "light.turn_on";
                        target.entity_id = "light.signify_netherlands_b_v_440400982842_light_3";
                        data = {
                          brightness_pct = "{{ [0, 0, 0, 0, 0, 0, 0, 30, 60, 80, 100][L] }}";
                          color_temp_kelvin = "{{ [3500, 3500, 3500, 3500, 3500, 3500, 3500, 3500, 3500, 4000, 4000][L] }}";
                          transition = fadeIn;
                        };
                      }
                    ];
                  }
                ];
                default = [
                  {
                    service = "light.turn_off";
                    target.entity_id = "light.signify_netherlands_b_v_440400982842_light_3";
                    data.transition = fadeOut;
                  }
                ];
              }
            ];
          };

          # Compute the auto-on level from sun elevation + clock and apply it.
          bedroom_lights_smart_on = {
            alias = "Bedroom Smart On";
            mode = "restart";
            sequence = [
              {
                service = "input_number.set_value";
                target.entity_id = "input_number.bedroom_light_level";
                data.value = ''
                  {% set e = state_attr('sun.sun', 'elevation') | float(0) %}
                  {% set h = now().hour %}
                  {% if e > 0 %}10
                  {% elif e > -6 %}7
                  {% elif h >= 23 or h < 6 %}2
                  {% else %}5
                  {% endif %}
                '';
              }
              {service = "script.apply_bedroom_level";}
            ];
          };

          # Set level=0 and apply (turns everything off with 5s fade).
          bedroom_lights_off = {
            alias = "Bedroom Lights Off";
            mode = "restart";
            sequence = [
              {
                service = "input_number.set_value";
                target.entity_id = "input_number.bedroom_light_level";
                data.value = 0;
              }
              {service = "script.apply_bedroom_level";}
            ];
          };
        };
      scene = builtins.fromJSON (builtins.readFile (haData + "/scenes.json"));

      input_number = {
        bedroom_light_level = {
          name = "Bedroom Light Level";
          min = 0;
          max = 10;
          step = 1;
          icon = "mdi:lightbulb-on-outline";
        };
      };

      input_boolean = {
        # Set by double-press on dimmer brightness up. When true, the next
        # smart-on call jumps to level 10 instead of auto. Cleared on off press.
        bedroom_override_full = {
          name = "Bedroom Full Override";
          icon = "mdi:flash";
        };
        # Latched while a dimmer brightness UP button is being held; the
        # ramp loop runs as long as this is on.
        dim_up_holding = {
          name = "Dim Up Held";
          icon = "mdi:arrow-up-bold";
        };
        dim_down_holding = {
          name = "Dim Down Held";
          icon = "mdi:arrow-down-bold";
        };
      };
    };
  };
}
