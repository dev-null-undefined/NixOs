{lib, ...}: let
  # Native Wayland toolkit for JBR. Avoids XWayland upscaling glitches on
  # HiDPI panels (mouse trails, blurry text, misplaced popups) seen on x1.
  vmOption = "-Dawt.toolkit.name=WLToolkit";
in {
  home.activation.jetbrainsVmOptions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -eu
    jb_dir="$HOME/.config/JetBrains"
    [ -d "$jb_dir" ] || exit 0
    line=${lib.escapeShellArg vmOption}
    for d in "$jb_dir"/*/; do
      [ -d "$d" ] || continue
      base=$(basename "$d")
      key=$(printf '%s' "$base" | sed -E 's/[0-9.]+$//' | tr '[:upper:]' '[:lower:]')
      case "$key" in
        intellijidea) product=idea ;;
        *) product="$key" ;;
      esac
      f="$d$product"64.vmoptions
      if [ -f "$f" ]; then
        if ! grep -qxF -- "$line" "$f"; then
          $DRY_RUN_CMD printf '%s\n' "$line" >> "$f"
        fi
      else
        $DRY_RUN_CMD printf '%s\n' "$line" > "$f"
      fi
    done
  '';
}
