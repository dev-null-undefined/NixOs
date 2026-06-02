{
  # Hyprlock 0.9.5 does not register `auth` as a Hyprlang category, so
  # nested `auth { fingerprint { ... } }` is silently ignored. Must use
  # flat colon-separated keys. The ready/present message is exposed as
  # $FPRINTPROMPT and must be referenced from a label widget to render.
  programs.hyprlock.settings = {
    "auth:fingerprint:enabled" = true;
    "auth:fingerprint:ready_message" = "Touch fingerprint reader to unlock";
    "auth:fingerprint:present_message" = "Scanning...";
    "auth:fingerprint:retry_delay" = 100;

    label = [
      {
        text = "$FPRINTPROMPT";
        color = "rgb(e0def4)";
        font_size = 16;
        font_family = "Inter";
        position = "0, -150";
        halign = "center";
        valign = "center";
      }
    ];
  };
}
