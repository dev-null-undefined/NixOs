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
      # Faster key repeat for vim-style editing
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
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
    };
  };
}
