{pkgs, ...}: let
  peda = pkgs.fetchFromGitHub {
    owner = "longld";
    repo = "peda";
    rev = "84d38bda505941ba823db7f6c1bcca1e485a2d43";
    hash = "sha256-vtNJ9WHCUtZmIn/IXwwtKrZx1i/az+gMmW6fLd67QYQ=";
  };
  dashboard = pkgs.fetchFromGitHub {
    owner = "cyrus-and";
    repo = "gdb-dashboard";
    rev = "05b31885798f16b1c1da9cb78f8c78746dd3557e";
    hash = "sha256-x3XcAJdj2Q8s+ZkIBHpGZvCroedPzBmqt5W9Hc1FL7s=";
  };
in ''
  alias gppo='g++ --std=c++17 -Wall -pedantic -Wno-long-long -g -fno-omit-frame-pointer -Wunused-variable -Wtrigraphs -trigraphs -O0'
  alias gpp='g++ --std=c++17 -Wall -pedantic -Wno-long-long -g -fno-omit-frame-pointer -Wunused-variable -Wtrigraphs -trigraphs -O2'

  gdb-peda() {
    gdb "$@" -ex "source ${peda}/peda.py"
  }

  gdb-dash() {
    gdb "$@" -ex "source ${dashboard}/.gdbinit"
  }

  gdb-gef() {
    gef "$@"
  }

  gdb-pwn() {
    pwndbg "$@"
  }

  gdb-c() {
    cgdb "$@"
  }

  vimg() {
    nvim "$1"
    gpp -o /tmp/a.out "$1" || return 1
    shift 1
    /tmp/a.out "$@"
  }

  gppa() {
    gpp -o /tmp/a.out "$@" || return 1
    /tmp/a.out
  }
''
