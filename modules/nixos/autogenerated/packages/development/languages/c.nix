{
  pkgs,
  lib,
  config,
  ...
}: {
  # C perf debugging variables
  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = true;
    "kernel.kptr_restrict" = false;
  };

  environment.systemPackages = with pkgs;
    [
      glibc
      patchelf

      strace
      ltrace

      config.boot.kernelPackages.perf
      perf-tools

      bintools-unwrapped

      # Disassemblers
      radare2

      # C++ intepreter
      cling

      # Clang
      clang_14
      lldb_14
      libclang
      clang-tools_14
      clang-manpages
      clang-analyzer

      # CMake
      cmake

      # Make
      gnumake
      remake

      # Compiler
      gcc

      # C++ debugger
      gdb

      # lsp server for C++
      ccls
      # Man pages for stl
      stdman

      # dev tools
      valgrind
    ]
    ++ (lib.lists.optionals (config.nixpkgs.system == "x86_64-linux") [
      # Multilib support
      gcc_multi
      clang_multi
    ])
    ++ (lib.lists.optionals (config.services.xserver.enable) [ghidra]);
}
