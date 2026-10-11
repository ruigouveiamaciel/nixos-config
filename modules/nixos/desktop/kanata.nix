{pkgs, ...}: {
  environment.systemPackages = let
    kanataUnit = "kanata-framework-12.service";
  in [
    (pkgs.writeShellScriptBin "kanata-kill" ''
      exec sudo systemctl stop "${kanataUnit}"
    '')

    (pkgs.writeShellScriptBin "kanata-start" ''
      exec sudo systemctl start "${kanataUnit}"
    '')
  ];

  services.kanata = {
    enable = true;

    keyboards.framework-12-kbd = {
      # ls -l /dev/input/by-path/ | grep kbd
      devices = ["/dev/input/by-path/platform-i8042-serio-0-event-kbd"];

      extraDefCfg = "concurrent-tap-hold yes";

      config = ''
        (defvar
          tap-hold-timeout 150
          macro-gap 100

          tmux1 (macro M-1 $macro-gap A-1)
          tmux2 (macro M-1 $macro-gap A-2)
          tmux3 (macro M-1 $macro-gap A-3)
          tmux4 (macro M-1 $macro-gap A-4)
          tmux5 (macro M-1 $macro-gap A-5)
          tmux6 (macro M-1 $macro-gap A-6)
          tmux7 (macro M-1 $macro-gap A-7)
          tmux8 (macro M-1 $macro-gap A-8)
          tmux9 (macro M-1 $macro-gap A-9)
        )

        (deflocalkeys-linux
          bslash 41
          abracket 86
          cedilla 39
          comma 51
          dot 52
          minus 53
          ordinal 40
          tilde 43
          plus 26
          acute 27
          apostrophe 12
          guillemet 13
        )

        (defsrc
          esc    f1       f2   f3   f4   f5   f6   f7   f8   f9    f10     f11        f12       del
          bslash 1        2    3    4    5    6    7    8    9     0       apostrophe guillemet bspc
          tab    q        w    e    r    t    y    u    i    o     p       plus       acute     ret
          caps   a        s    d    f    g    h    j    k    l     cedilla ordinal    tilde
          lsft   abracket z    x    c    v    b    n    m    comma dot     minus      rsft
          lctl   lmet     lalt           spc            ralt rctl  left    down       up        right
        )

        (defalias
          q (tap-hold $tap-hold-timeout $tap-hold-timeout q (layer-while-held switch))
          spc (tap-hold $tap-hold-timeout $tap-hold-timeout spc (layer-while-held sym))
          ralt (tap-hold $tap-hold-timeout $tap-hold-timeout bspc (layer-while-held func))
          lalt (tap-hold $tap-hold-timeout $tap-hold-timeout esc (layer-while-held num))
          a (tap-hold $tap-hold-timeout $tap-hold-timeout a lmet)
          s (tap-hold $tap-hold-timeout $tap-hold-timeout s lalt)
          d (tap-hold $tap-hold-timeout $tap-hold-timeout d lctl)
          f (tap-hold $tap-hold-timeout $tap-hold-timeout f lsft)
          j (tap-hold $tap-hold-timeout $tap-hold-timeout j rsft)
          k (tap-hold $tap-hold-timeout $tap-hold-timeout k rctl)
          l (tap-hold $tap-hold-timeout $tap-hold-timeout l lalt)
          cedilla (tap-hold $tap-hold-timeout $tap-hold-timeout cedilla rmet)
        )

        (deflayer base
          esc    f1   f2    f3   f4   f5   f6   f7   f8    f9    f10      f11   f12  del
          XX     1    2     3    4    5    6    7    8     9     0        XX    XX   bspc
          tab    @q   w     e    r    t    y    u    i     o     p        XX    XX   ret
          caps   @a   @s    @d   @f   g    h    @j   @k    @l    @cedilla XX    XX
          lshift XX   z     x    c    v    b    n    m     comma dot      minus XX
          lctl   XX   @lalt           @spc           @ralt XX    XX       XX    XX   right
        )

        (deflayer sym
          XX   XX       XX       XX         XX      XX      XX        XX      XX   XX   XX         XX           XX   XX
          XX   XX       XX       XX         XX      XX      XX        XX      XX   XX   XX         XX           XX   XX
          XX   S-1      AG-2     AG-e       bslash  S-5     S-6       S-7     S-8  S-9  S-0        XX           XX   XX
          XX   S-bslash S-2      S-4        S-acute S-tilde tilde     acute   AG-7 AG-0 apostrophe XX           XX
          XX   XX       abracket S-abracket S-3     S-plus  S-ordinal ordinal plus AG-8 AG-9       S-apostrophe XX
          XX   XX       XX                          XX                        XX   XX   XX         XX           XX   XX
        )

        (deflayer switch
          XX   XX   XX     XX     XX     XX     XX     XX     XX     XX     XX     XX   XX   XX
          XX   XX   XX     XX     XX     XX     XX     XX     XX     XX     XX     XX   XX   XX
          XX   XX   M-2    M-3    M-4    M-5    M-6    M-7    M-8    M-9    M-0    XX   XX   XX
          XX   XX   $tmux1 $tmux2 $tmux3 $tmux4 $tmux5 $tmux6 $tmux7 $tmux8 $tmux9 XX   XX
          XX   XX   XX     XX     XX     XX     XX     XX     XX     XX     XX     XX   XX
          XX   XX   XX                   XX                   XX     XX     XX     XX   XX   XX
        )

        (deflayer num
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   7    8    9    XX   XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   4    5    6    XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   0    1    2    3    XX   XX
          XX   XX   XX             XX             XX   XX   XX   XX   XX   XX
        )

        (deflayer func
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX    XX    XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX    XX    XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX    XX    XX   XX   XX
          XX   XX   XX   XX   XX   XX   left down up   right prtsc XX   XX
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX    XX    XX   XX
          XX   XX   XX             XX             XX   XX    XX    XX   XX   XX
        )

        (deflayer empty
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
          XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
          XX   XX   XX             XX             XX   XX   XX   XX   XX   XX
        )
      '';
    };
  };
}
