{osConfig, ...}: let
  suffix = osConfig.generated.network-manager.network-profiles.vpn.cdn77.privateKeySuffix;
in {
  programs.waybar = {
    settings = {
      primary = {
        modules-right = [
          "network#wg-cdn77"
        ];
        "network#wg-cdn77" = {
          interface = "wg-cdn77";
          interval = 3;
          format = " {ifname}";
          format-disconnected = " VPN";
          tooltip-format = ''
            {ifname} ({ipaddr}/{cidr})
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          tooltip-format-disconnected = "CDN77 VPN: Disconnected";
          on-click = ''
            CONN_NAME="CDN77 VPN${suffix}"
            if nmcli con show --active | grep -q "$CONN_NAME"; then
              nmcli con down "$CONN_NAME";
            else
              nmcli con up "$CONN_NAME";
            fi
          '';
          on-click-right = "nm-connection-editor";
        };
      };
    };
  };
}
