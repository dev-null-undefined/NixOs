# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages/packages.nix
    ];
  specialisation = {
    gnome.configuration = {
      system.nixos = {
        label = "gnome";
        tags = [ "gnome" ];
      };
      imports = [
        ./gnome.nix
      ];
    };
    i3.configuration = {
      system.nixos = {
        label = "i3";
        tags = [ "i3" ];
      };
      imports = [
        ./i3.nix
      ];
    };
  };
  # Use the systemd-boot EFI boot loader.
  boot = {
      loader = {
        grub = {
          efiSupport = true;
          device = "nodev";
          useOSProber = true;
        };
        efi.canTouchEfiVariables = true;
      };
      resumeDevice = "/dev/nvme1n1p3";
  };

  networking.hostName = "idk";
  networking.hostId = "69faa160";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Prague";
  # Time fix dual boot with windows https://nixos.wiki/wiki/Dual_Booting_NixOS_and_Windows

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  environment.pathsToLink = [ "/libexec" ];


  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;


  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };


  users.users.martin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    useDefaultShell = false;
  };

  # No sudo password 
  security.sudo.extraRules = [{ 
      users = [ "martin" ];
      commands = [{ 
	  command = "ALL";
	  options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
      }];
  }];
  
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts
    dina-font
    proggyfonts
    font-awesome_4
    font-awesome
    meslo-lgs-nf
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
