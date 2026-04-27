{
  config,
  pkgs,
  ...
}: {
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  users.users.nixremote = {
    isNormalUser = true;
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = config.myConstants.users.rui.authorized-keys;
  };

  nix.settings.trusted-users = ["nixremote"];
}
