{
  # Rules to allow flashing ZSA keyboards
  services.udev = {
    enable = true;
    extraRules = ''
      # Rules for Oryx web flashing and live training
      KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

      # Keymapp Flashing rules for the Voyager
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"

      # Make ZSA not be shown as a controller in Steam
      SUBSYSTEM=="input", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1977", ENV{ID_INPUT_JOYSTICK}=""
    '';
  };
}
