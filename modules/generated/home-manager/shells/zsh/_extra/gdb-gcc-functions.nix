''
  alias gppo='g++ --std=c++17 -Wall -pedantic -Wno-long-long -g -fno-omit-frame-pointer -Wunused-variable -Wtrigraphs -trigraphs -O0'
  alias gpp='g++ --std=c++17 -Wall -pedantic -Wno-long-long -g -fno-omit-frame-pointer -Wunused-variable -Wtrigraphs -trigraphs -O2'

  gdb-clear() {
    rm -rf ~/.gdbinit
  }

  gdb-peda() {
    gdb-clear
    ln -s /home/martin/.gdb-configs/peda/pedainit /home/martin/.gdbinit
    gdb "$@"
  }

  gdb-dash() {
    gdb-clear
    ln -s /home/martin/.gdb-configs/dashboard.py /home/martin/.gdbinit
    gdb "$@"
  }

  gdb-gef() {
    gdb-clear
    gef "$@"
  }

  gdb-pwn() {
    gdb-clear
    pwndbg "$@"
  }

  gdb-c() {
    gdb-clear
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
