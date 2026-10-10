{
  services.kanata = {
    enable = true;

    keyboards.laptop = {
      # ls -l /dev/input/by-path/ | grep kbd
      devices = ["/dev/input/by-path/platform-i8042-serio-0-event-kbd"];

      config = ''
        (defsrc
          esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
          tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
          caps a    s    d    f    g    h    j    k    l    ;    '    ret
          lsft z    x    c    v    b    n    m    ,    .    /    rsft
          lctl lmet lalt           spc            ralt rmet rctl
        )

        (defalias
          ;; Left hand
          a (tap-hold-release 150 150 a lmet)
          s (tap-hold-release 150 150 s lalt)
          d (tap-hold-release 150 150 d lctl)
          f (tap-hold-release 150 150 f lsft)
          ;; Right hand
          j (tap-hold-release 150 150 j rsft)
          k (tap-hold-release 150 150 k rctl)
          l (tap-hold-release 150 150 l lalt)
          scl (tap-hold-release 150 150 ; rmet)
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
