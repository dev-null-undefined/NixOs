{
  pkgs,
  lib,
  ...
}: {
  # Betaflight Configurator (below) ships no udev rules. Flight controllers need:
  #  - DFU bootloader access for firmware flashing (raw libusb device, root-only by default)
  #  - the serial VCP hidden from ModemManager, which otherwise probes /dev/ttyACM* as a
  #    modem and steals the port. ModemManager stays enabled here (WWAN modem on x1), so we
  #    flag just the FC's VID:PID with ID_MM_DEVICE_IGNORE instead of disabling the daemon.
  services.udev.extraRules = ''
    # DFU bootloader — STM32 (0483) and AT32/Artery (2e3c) MCUs
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess", MODE="0660", GROUP="dialout"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", TAG+="uaccess", MODE="0660", GROUP="dialout"
    # STM32 Virtual COM Port — normal MSP connection
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
  '';

  generated.packages.development.ides = {
    jetbrains.enable = lib.mkDefault true;
    vscode.enable = lib.mkDefault true;
    emacs.enable = lib.mkDefault true;
    android.enable = lib.mkDefault true;
  };

  services.gnome.sushi.enable = true;

  environment.systemPackages = with pkgs; [
    nextcloud-client

    headsetcontrol # Logitech headphones controll
    solaar # Logitech Unifying/Bolt receiver manager

    thunderbird

    # etcher # ISO etcher

    # teams unmaintained

    anki # anky

    gtkwave

    tesseract # OCR engine

    gnome-screenshot
    flameshot

    gnome-usage
    gnome-terminal
    gnome-power-manager

    gnuplot

    telegram-desktop # Telegram desctop client

    # element-desktop # Matrix desctop client
    # gomuks # Matrix terminal client

    libreoffice
    onlyoffice-desktopeditors

    copyq

    lxappearance
    font-manager

    kdePackages.ark # archive manager
    kdePackages.partitionmanager

    gitg
    git-open

    arandr

    ccls
    bash-language-server
    typescript-language-server
    shellcheck

    # Spell checking
    hunspell
    hunspellDicts.en-us
    hunspellDicts.cs-cz

    proselint

    # FPV PooooG!
    betaflight-configurator
  ];
}
