# Pin waybar's source to upstream master HEAD until a release ships the
# tooltip-bandwidth divisor fix from commits 25089b24 (Mar 2 2026) and
# c0c1a422 (Mar 21 2026). Both landed after the 0.15.0 tag (Feb 6 2026).
#
# Without this override, every {bandwidthDownBits}/{bandwidthUpBits} token in a
# tooltip-format shows values 1000× too small (interval_.count() is in ms, but
# the v0.15.0 tooltip code path divides by it as if it were seconds).
#
# The assertion below makes this overlay self-removing: as soon as nixpkgs
# advances past 0.15.0, eval fails with a message telling us to delete it.
final: super: let
  expectedUpstreamVersion = "0.15.0";
in {
  waybar =
    if super.waybar.version != expectedUpstreamVersion
    then
      throw ''
        overlays/waybar-bandwidth-fix.nix: nixpkgs now ships waybar ${super.waybar.version}
        (override was pinned against ${expectedUpstreamVersion}).

        The upstream tooltip-bandwidth fix is likely now in this release — verify by
        checking that src/modules/network.cpp uses `elapsed_seconds` (not
        `interval_.count()`) in the tooltip arglist, then delete this overlay and the
        entry for it in overlays/default.nix.
      ''
    else
      super.waybar.overrideAttrs (oldAttrs: {
        version = "0.15.0-unstable-2026-05-14";
        src = final.fetchFromGitHub {
          owner = "Alexays";
          repo = "Waybar";
          rev = "05945748dccce28bf96d26d8f64a9e69a8dd49ba";
          hash = "sha256-51R3mIt8cLNvh/X5qe9vOqeJCj0U9KRyemVE5y+OhiU=";
        };
        # master added cava as an auto-detected meson subproject; nixpkgs doesn't
        # supply it, and sandboxed builds can't fetch wrap subprojects.
        mesonFlags = (oldAttrs.mesonFlags or []) ++ ["-Dcava=disabled"];
        # `waybar --version` still prints upstream's "0.15.0" since meson.build
        # hasn't been bumped on master, so versionCheckHook fails on our pinned
        # derivation version string. Skip it.
        doInstallCheck = false;
      });
}
