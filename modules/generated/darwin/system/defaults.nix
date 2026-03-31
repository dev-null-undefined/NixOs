{
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      minimize-to-application = true;
      mru-spaces = false; # Don't rearrange spaces based on most recent use
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv"; # List view
      FXEnableExtensionChangeWarning = false;
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
      # Faster key repeat for vim-style editing
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };

    menuExtraClock = {
      Show24Hour = true;
      ShowSeconds = true;
    };

    trackpad = {
      Clicking = true; # Tap to click
      TrackpadThreeFingerDrag = true;
    };

    CustomUserPreferences = {
      # Disable screenshot shadow
      "com.apple.screencapture" = {
        disable-shadow = true;
      };

      # Maccy clipboard manager
      "org.p0deje.Maccy" = {
        pasteByDefault = true;
        showInStatusBar = true;
        popupPosition = "center"; # show in center of screen
      };
    };
  };
}
