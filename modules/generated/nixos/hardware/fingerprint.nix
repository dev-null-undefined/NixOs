{
  # GDM auto-wires a parallel `gdm-fingerprint` PAM service when fprintd is
  # enabled; setting fprintAuth on `login` or `gdm-password` would block the
  # password prompt, so those services are intentionally left alone.
  services.fprintd.enable = true;

  security.pam.services = {
    sudo.fprintAuth = true;
    su.fprintAuth = true;
    "polkit-1".fprintAuth = true;
    hyprlock.fprintAuth = true;
  };
}
