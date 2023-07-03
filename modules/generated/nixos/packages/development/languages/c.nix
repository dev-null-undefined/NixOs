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
      lldb_14
      clang-tools
      clang-manpages
      clang-analyzer

      # CMake
      cmake

      # Make
      gnumake
      remake

      # Compiler
      gcc13

      # C++ debugger
      gdb
      gef
      pwndbg
      cgdb

      rr

      # lsp server for C++
      ccls
      # Man pages for stl
      stdman
      # Offline cppreference
      cppreference-doc

      # dev tools
      valgrind

      # static analysis tool
      cppcheck
      cpplint

      # makefile checker  
      checkmake
    ]
    ++ (lib.lists.optionals (config.nixpkgs.system == "x86_64-linux") [
      # Multilib support
      #gcc_multi
      clang_multi
    ])
    ++ (lib.lists.optionals (config.services.xserver.enable || config.generated.de.enable) [ghidra]);
}
