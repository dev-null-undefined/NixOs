{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    obsidian # Markdown editor

    # advanced hex editor
    imhex

    gnome.ghex
  ];
}
