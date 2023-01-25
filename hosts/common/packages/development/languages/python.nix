{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.programming-languages.python.enable) {
  environment.systemPackages = with pkgs; [
    # Python
    python39Packages.ueberzug

    (python3.withPackages
      (e: [e.matplotlib e.pygments e.numpy e.tkinter e.pandas]))
  ];
}
