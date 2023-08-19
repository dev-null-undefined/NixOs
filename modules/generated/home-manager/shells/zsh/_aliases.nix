{lib'}: let
  repeateString = lib'.internal.repeateString;
in
  {
    gen-pass = "date +%s | sha256sum | base64 | head -c 32 ; echo";

    kill-window = ''xprop _NET_WM_PID | sed "s/.*=//g" | xargs kill -9'';

    du = "ncdu";
    df = "duf";
    ps = "procs";
    grep = "grep --color";
    sgrep = "grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS}";

    ls = "lsd";
    l = "lsd -Fh"; #size,show type,human readable
    la = "lsd -AFh"; #long list,show almost all,show type,human readable
    lla = "lsd -lAFh"; #long list,show almost all,show type,human readable
    ll = "lsd -lh"; #long list
    ldot = "lsd -hld .*";

    cat = "bat -p";

    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";

    mkd = "mkdir -pv";

    sc = "systemctl";

    f = "fuck";
    j = "z -I";

    vim = "nvim";

    svim = "sudoedit";
  }
  // (builtins.foldl' (acc: value: let
    key = repeateString "." value;
  in
    {
      "${key}" = "cd " + repeateString "../" (value - 1);
    }
    // acc) {}
  (lib'.lists.range 2 10))
