{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  dataDir = "/var/lib/hass";
  haData = ./_home-assistant-data;

  # UniFi AP MAC → room name. Inferred from the AP friendly_name in the
  # UniFi controller (Obývák / Ložnice / Pracovna [Martínek]).
  apToRoom = {
    "6c:63:f8:51:51:01" = "Living Room";
    "9c:05:d6:d9:fd:61" = "Bedroom";
    "9c:05:d6:da:06:59" = "Martin Bedroom";
  };

  # Build a template sensor that resolves a person's current room from
  # the most-recently-changed home device_tracker that exposes ap_mac.
  mkPersonRoom = {
    name,
    slug,
    person,
    trackers,
  }: {
    name = "${name} Room";
    unique_id = "${slug}_room";
    state = ''
      {% set ns = namespace(ap="", max_ts=0) %}
      {% for eid in ${builtins.toJSON trackers} %}
        {% if states(eid) == 'home' %}
          {% set ap = state_attr(eid, 'ap_mac') %}
          {% if ap %}
            {% set ts = states[eid].last_changed.timestamp() %}
            {% if ts > ns.max_ts %}
              {% set ns.max_ts = ts %}{% set ns.ap = ap %}
            {% endif %}
          {% endif %}
        {% endif %}
      {% endfor %}
      ${lib.concatStringsSep "" (lib.imap0 (i: name: let
        mac = builtins.elemAt (builtins.attrNames apToRoom) i;
        kw =
          if i == 0
          then "if"
          else "elif";
      in "{% ${kw} ns.ap == '${mac}' %}${name}\n") (builtins.attrValues apToRoom))}{% elif states('${person}') == 'home' %}Home
      {% else %}Away
      {% endif %}
    '';
  };

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

  # Remove stale per-dashboard YAML symlinks left over from when Health,
  # Homelab and All-entities lived as separate dashboards — they are now
  # merged as tabs in the main overview. Also force the system default panel
  # to our YAML dashboard so users land on the merged overview instead of
  # the built-in (and now redundant) /home/overview panel.
  systemd.services.home-assistant.preStart = lib.mkAfter ''
    rm -f ${dataDir}/ui-lovelace-health.yaml \
          ${dataDir}/ui-lovelace-homelab.yaml \
          ${dataDir}/ui-lovelace-all.yaml
    file=${dataDir}/.storage/frontend.system_data
    if [ -f "$file" ]; then
      ${pkgs.jq}/bin/jq '.data.core.default_panel = "nixos-lovelace"' "$file" > "$file.tmp" \
        && mv "$file.tmp" "$file"
    fi
  '';

  services.home-assistant = {
    enable = true;
    configDir = dataDir;

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mushroom
      mini-graph-card
      button-card
      card-mod
      auto-entities
      plotly-chart-card
    ];

    customComponents = [
      pkgs.home-assistant-custom-components.xiaomi_miot
      pkgs.home-assistant-custom-components.midea_ac_lan
      pkgs.home-assistant-electrolux-status
    ];

    lovelaceConfig = builtins.fromJSON (builtins.readFile (haData + "/dashboard.json"));

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
      "homekit"
      "xbox"
      "samsungtv"
      "jellyfin"
      "adguard"
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
      # 2026.8+ lovelace schema: top-level `lovelace.mode` is removed.
      # The default Overview dashboard is auto-declared by the NixOS module as
      # `dashboards.nixos-lovelace` whenever `lovelaceConfig` is set, and
      # `resource_mode = "yaml"` is auto-set whenever `customLovelaceModules`
      # is non-empty — both apply here. Health / Homelab / All-entities used
      # to be separate dashboards; they now live as tabs inside the main
      # overview, so no extra dashboards are declared.

      # Statistics-derived helpers powering the Health dashboard.
      sensor = [
        {
          platform = "statistics";
          name = "Weight 7d change";
          unique_id = "withings_weight_7d_change";
          entity_id = "sensor.withings_weight";
          state_characteristic = "change";
          sampling_size = 200;
          max_age.days = 7;
        }
        {
          platform = "statistics";
          name = "Weight 30d change";
          unique_id = "withings_weight_30d_change";
          entity_id = "sensor.withings_weight";
          state_characteristic = "change";
          sampling_size = 1000;
          max_age.days = 30;
        }
      ];

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
              {
                variables = {
                  L = "{{ states('input_number.bedroom_light_level') | int(0) }}";
                  # Callers may pass `transition: <seconds>` to override the
                  # default fadeIn/fadeOut for one apply (e.g. snappy 0.3s
                  # for dimmer taps, 0.15s during the hold ramp).
                  t_in = "{{ transition | default(${toString fadeIn}) }}";
                  t_out = "{{ transition | default(${toString fadeOut}) }}";
                };
              }
              # Portable Lamp (svetluška) — always-on baseline from L=1
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
                          brightness_pct = "{{ [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100][L] }}";
                          color_temp_kelvin = "{{ [2700, 2000, 2200, 2700, 2700, 2700, 2700, 3000, 3300, 3700, 4000][L] }}";
                          transition = "{{ t_in }}";
                        };
                      }
                    ];
                  }
                ];
                default = [
                  {
                    service = "light.turn_off";
                    target.entity_id = "light.prenosna_svetluska_light";
                    data.transition = "{{ t_out }}";
                  }
                ];
              }
              # Wardrobe accent pair (top of wardrobe) — always-on baseline from L=1
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
                        target.entity_id = [
                          "light.wardrobe_left"
                          "light.wardrobe_right"
                        ];
                        data = {
                          brightness_pct = "{{ [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100][L] }}";
                          color_temp_kelvin = "{{ [2700, 2000, 2200, 2700, 2700, 2700, 2700, 3000, 3300, 3700, 4000][L] }}";
                          transition = "{{ t_in }}";
                        };
                      }
                    ];
                  }
                ];
                default = [
                  {
                    service = "light.turn_off";
                    target.entity_id = [
                      "light.wardrobe_left"
                      "light.wardrobe_right"
                    ];
                    data.transition = "{{ t_out }}";
                  }
                ];
              }
              # Monitors — join at L=3 (the lowest snap: monitor + svetluška)
              {
                choose = [
                  {
                    conditions = [
                      {
                        condition = "template";
                        value_template = "{{ L >= 3 }}";
                      }
                    ];
                    sequence = [
                      {
                        service = "light.turn_on";
                        target.entity_id = [
                          "light.signify_netherlands_b_v_440400982842_light_2"
                          "light.signify_netherlands_b_v_440400982842_light_3"
                        ];
                        data = {
                          brightness_pct = "{{ [0, 0, 0, 30, 40, 50, 60, 70, 80, 90, 100][L] }}";
                          color_temp_kelvin = "{{ [2700, 2700, 2700, 2700, 2700, 2700, 2700, 3000, 3300, 3700, 4000][L] }}";
                          transition = "{{ t_in }}";
                        };
                      }
                    ];
                  }
                ];
                default = [
                  {
                    service = "light.turn_off";
                    target.entity_id = [
                      "light.signify_netherlands_b_v_440400982842_light_2"
                      "light.signify_netherlands_b_v_440400982842_light_3"
                    ];
                    data.transition = "{{ t_out }}";
                  }
                ];
              }
              # Ceiling — joins at L=6 (the all-lights warm snap)
              {
                choose = [
                  {
                    conditions = [
                      {
                        condition = "template";
                        value_template = "{{ L >= 6 }}";
                      }
                    ];
                    sequence = [
                      {
                        service = "light.turn_on";
                        target.entity_id = "light.philips_915005998001_light";
                        data = {
                          brightness_pct = "{{ [0, 0, 0, 0, 0, 0, 60, 70, 80, 90, 100][L] }}";
                          color_temp_kelvin = "{{ [2700, 2700, 2700, 2700, 2700, 2700, 2700, 3000, 3300, 3700, 4000][L] }}";
                          transition = "{{ t_in }}";
                        };
                      }
                    ];
                  }
                ];
                default = [
                  {
                    service = "light.turn_off";
                    target.entity_id = "light.philips_915005998001_light";
                    data.transition = "{{ t_out }}";
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

          # Set the bedroom level to an explicit value and apply.
          # Used by dashboard snap-buttons. Takes `level` field (0–10).
          bedroom_set_level = {
            alias = "Bedroom Set Level";
            mode = "restart";
            fields.level = {
              description = "Target level (0–10).";
              example = 6;
              selector.number = {
                min = 0;
                max = 10;
                step = 1;
              };
            };
            sequence = [
              {
                service = "input_number.set_value";
                target.entity_id = "input_number.bedroom_light_level";
                data.value = "{{ level }}";
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

      template = [
        {
          sensor = [
            (mkPersonRoom {
              name = "Martin";
              slug = "martin";
              person = "person.martin";
              trackers = [
                "device_tracker.pixel_10_pro_4"
                "device_tracker.martins_macbook_air"
                "device_tracker.pixel_10_pro_5"
                "device_tracker.pixel_10_pro_7"
                "device_tracker.pixel_10_pro_3"
                "device_tracker.martin_s24"
                "device_tracker.martin_s_s24"
                "device_tracker.martin_mac_air"
              ];
            })
            (mkPersonRoom {
              name = "Úzdíl";
              slug = "uzdil";
              person = "person.uzdil";
              trackers = [
                "device_tracker.redmi_note_11_pro_5g"
                "device_tracker.xiaomi_17"
                "device_tracker.unifi_uzdil_macbook"
                "device_tracker.unifi_uzdil_macbook_2"
              ];
            })
            (mkPersonRoom {
              name = "Štefánko";
              slug = "stefanko";
              person = "person.stefanko";
              trackers = [
                "device_tracker.stefan_s_s24"
                "device_tracker.unifi_stefi_mac"
              ];
            })
            (mkPersonRoom {
              name = "Samira";
              slug = "samira";
              person = "person.samira";
              trackers = [
                "device_tracker.samirka_iphone"
                "device_tracker.samirka_mac_pro"
              ];
            })
            # Per-room occupancy counts (for surveillance history-graphs).
            {
              name = "Living Room Occupancy";
              unique_id = "living_room_occupancy";
              state = ''
                {{ [
                  states('sensor.martin_room'),
                  states('sensor.uzdil_room'),
                  states('sensor.stefanko_room'),
                  states('sensor.samira_room')
                ] | select('eq', 'Living Room') | list | count }}
              '';
              unit_of_measurement = "people";
            }
            {
              name = "Bedroom Occupancy";
              unique_id = "bedroom_occupancy";
              state = ''
                {{ [
                  states('sensor.martin_room'),
                  states('sensor.uzdil_room'),
                  states('sensor.stefanko_room'),
                  states('sensor.samira_room')
                ] | select('eq', 'Bedroom') | list | count }}
              '';
              unit_of_measurement = "people";
            }
            {
              name = "Martin Bedroom Occupancy";
              unique_id = "martin_bedroom_occupancy";
              state = ''
                {{ [
                  states('sensor.martin_room'),
                  states('sensor.uzdil_room'),
                  states('sensor.stefanko_room'),
                  states('sensor.samira_room')
                ] | select('eq', 'Martin Bedroom') | list | count }}
              '';
              unit_of_measurement = "people";
            }
            # Comma-separated list of people in each room (for "now" display).
            {
              name = "Living Room People";
              unique_id = "living_room_people";
              state = ''
                {%- set p = [] -%}
                {%- if states('sensor.martin_room') == 'Living Room' %}{%- set p = p + ['Martin'] -%}{%- endif %}
                {%- if states('sensor.uzdil_room') == 'Living Room' %}{%- set p = p + ['Úzdíl'] -%}{%- endif %}
                {%- if states('sensor.stefanko_room') == 'Living Room' %}{%- set p = p + ['Štefánko'] -%}{%- endif %}
                {%- if states('sensor.samira_room') == 'Living Room' %}{%- set p = p + ['Samira'] -%}{%- endif %}
                {{ p | join(', ') if p else 'empty' }}
              '';
            }
            {
              name = "Bedroom People";
              unique_id = "bedroom_people";
              state = ''
                {%- set p = [] -%}
                {%- if states('sensor.martin_room') == 'Bedroom' %}{%- set p = p + ['Martin'] -%}{%- endif %}
                {%- if states('sensor.uzdil_room') == 'Bedroom' %}{%- set p = p + ['Úzdíl'] -%}{%- endif %}
                {%- if states('sensor.stefanko_room') == 'Bedroom' %}{%- set p = p + ['Štefánko'] -%}{%- endif %}
                {%- if states('sensor.samira_room') == 'Bedroom' %}{%- set p = p + ['Samira'] -%}{%- endif %}
                {{ p | join(', ') if p else 'empty' }}
              '';
            }
            # TV channel/app, but shows "off" when the TV is off so history-graphs
            # and logbooks don't carry the previous channel forward indefinitely.
            {
              name = "TV Channel";
              unique_id = "tv_channel";
              state = ''
                {% set tv = states('media_player.77_oled') %}
                {% if tv in ['off','standby','unavailable','unknown'] %}off
                {% else %}{{ states('sensor.77_oled_tv_channel_name') or 'idle' }}{% endif %}
              '';
            }
            {
              name = "Martin Bedroom People";
              unique_id = "martin_bedroom_people";
              state = ''
                {%- set p = [] -%}
                {%- if states('sensor.martin_room') == 'Martin Bedroom' %}{%- set p = p + ['Martin'] -%}{%- endif %}
                {%- if states('sensor.uzdil_room') == 'Martin Bedroom' %}{%- set p = p + ['Úzdíl'] -%}{%- endif %}
                {%- if states('sensor.stefanko_room') == 'Martin Bedroom' %}{%- set p = p + ['Štefánko'] -%}{%- endif %}
                {%- if states('sensor.samira_room') == 'Martin Bedroom' %}{%- set p = p + ['Samira'] -%}{%- endif %}
                {{ p | join(', ') if p else 'empty' }}
              '';
            }
            # BMI derived from Withings height + weight.
            {
              name = "Withings BMI";
              unique_id = "withings_bmi";
              unit_of_measurement = "kg/m²";
              state_class = "measurement";
              state = ''
                {% set w = states('sensor.withings_weight') | float(0) %}
                {% set h = states('sensor.withings_height') | float(0) %}
                {% if w > 0 and h > 0 %}
                  {{ (w / (h * h)) | round(1) }}
                {% else %}
                  unknown
                {% endif %}
              '';
              availability = ''
                {{ states('sensor.withings_weight') not in ['unknown','unavailable','none']
                   and states('sensor.withings_height') not in ['unknown','unavailable','none'] }}
              '';
            }
          ];
        }
      ];

      input_boolean = {
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
