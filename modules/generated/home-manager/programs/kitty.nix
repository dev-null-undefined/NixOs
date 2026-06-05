{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "MesloLGS Nerd Font Mono";
      font_size = 13;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      # Disable kitty's config auto-reload watcher. The config is a symlink to a
      # flat file at the /nix/store root, so kitty 0.47.x's __watch_conf__ kitten
      # follows it and recursively watches the entire store (~350k entries),
      # exhausting the inotify watch limit (ENOSPC) and starving other apps (e.g.
      # waybar's battery module). A negative value disables the watcher; config is
      # immutable in the store anyway, so reload manually via ctrl+shift+f5 /
      # SIGUSR1 after a rebuild. Revert once the upstream fix
      # (kovidgoyal/kitty#10102, #10104, merged 2026-06-02) ships.
      auto_reload_config = -1;
    };
  };
}
