{
  services.kanata = {
    enable = true;

    keyboards.framework-12 = {
      # ls -l /dev/input/by-path/ | grep kbd
      devices = ["/dev/input/by-path/platform-i8042-serio-0-event-kbd"];

      extraDefCfg = "concurrent-tap-hold yes";

      config = ''
        (defvar
          tap-hold-timeout 200
          chord-timeout 75
          chord-timeout-2 50
        )

        (defchordsv2
          (e r) tab  $chord-timeout-2 first-release ()
          (d f) caps $chord-timeout-2 first-release ()
          (u i) bspc $chord-timeout-2 first-release ()
          (j k) ret  $chord-timeout-2 first-release ()
        )

        (defsrc
          esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
          tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
          caps a    s    d    f    g    h    j    k    l    ;    '    ret
          lsft z    x    c    v    b    n    m    ,    .    /    rsft
          lctl lmet lalt           spc            ralt rmet rctl
        )

        (defalias
          ;; Left hand
          a (tap-hold $tap-hold-timeout $tap-hold-timeout a lmet)
          s (tap-hold $tap-hold-timeout $tap-hold-timeout s lalt)
          d (tap-hold $tap-hold-timeout $tap-hold-timeout d lctl)
          f (tap-hold $tap-hold-timeout $tap-hold-timeout f lsft)
          ;; Right hand
          j (tap-hold $tap-hold-timeout $tap-hold-timeout j rsft)
          k (tap-hold $tap-hold-timeout $tap-hold-timeout k rctl)
          l (tap-hold $tap-hold-timeout $tap-hold-timeout l lalt)
          scl (tap-hold $tap-hold-timeout $tap-hold-timeout ; rmet)
        )

        (deflayer base
          esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
          tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
          caps @a   @s   @d   @f   g    h    @j   @k   @l   @scl '    ret
          lsft z    x    c    v    b    n    m    ,    .    /    rsft
          lctl lmet lalt           spc            ralt rmet rctl
        )
      '';
    };
  };
}
