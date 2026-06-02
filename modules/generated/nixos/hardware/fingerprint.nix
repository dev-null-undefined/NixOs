{
  # GDM auto-wires a parallel `gdm-fingerprint` PAM service when fprintd is
  # enabled; setting fprintAuth on `login` or `gdm-password` would block the
  # password prompt, so those services are intentionally left alone.
  services.fprintd.enable = true;

  security.pam.services = {
    sudo.fprintAuth = true;
    su.fprintAuth = true;
    "polkit-1".fprintAuth = true;
    # Hyprlock owns the fprintd device directly via D-Bus when
    # `auth.fingerprint.enabled` is set. If pam_fprintd is also in the PAM
    # stack, both clients race to Claim the device and the loser fails with
    # "Device was already claimed", silently falling through to password.
    hyprlock.fprintAuth = false;
  };
}
