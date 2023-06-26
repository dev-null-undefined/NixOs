{pkgs, ...}: {
  services.gnome.sushi.enable = true;

  environment.systemPackages = with pkgs; [
    gnome.nautilus-python

    pcmanfm

    cinnamon.nemo-with-extensions
    cinnamon.nemo-fileroller
    cinnamon.nemo-python
    cinnamon.folder-color-switcher
    nemo-qml-plugin-dbus

    dropbox
  ];
}
