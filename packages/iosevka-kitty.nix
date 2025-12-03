{pkgs, ...}:
pkgs.iosevka.override {
  set = "Kitty";
  privateBuildPlan = ''
    [buildPlans.IosevkaKitty]
    family = "Iosevka Kitty"
    spacing = "term"
    serifs = "sans"
    noCvSs = false
    exportGlyphNames = true

      [buildPlans.IosevkaKitty.variants]
      inherits = "ss14"

        [buildPlans.IosevkaKitty.variants.design]
        number-sign = "upright"
        dollar = "open"
        cent = "open"

    [buildPlans.IosevkaKitty.weights.Regular]
    shape = 400
    menu = 400
    css = 400

    [buildPlans.IosevkaKitty.weights.Bold]
    shape = 700
    menu = 700
    css = 700

    [buildPlans.IosevkaKitty.slopes.Upright]
    angle = 0
    shape = "upright"
    menu = "upright"
    css = "normal"

    [buildPlans.IosevkaKitty.slopes.Italic]
    angle = 9.4
    shape = "italic"
    menu = "italic"
    css = "italic"
  '';
}
