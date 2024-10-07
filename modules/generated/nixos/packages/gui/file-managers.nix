{pkgs, ...}: {
  services.gnome.sushi.enable = true;

  environment.systemPackages = with pkgs; [
    nautilus-python

    pcmanfm

    nemo-with-extensions
    nemo-fileroller
    nemo-python
    folder-color-switcher
    nemo-qml-plugin-dbus
  ];
}
