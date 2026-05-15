{pkgs, ...}: {
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # TODO: Improve this
  users.users.nixremote = {
    isNormalUser = true;
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHB1NAWh3LewF6HYnLT8J6n/IMl4hw4RAcbJbnKYdXpX nix-daemon@acv-4-c-11"
    ];
  };

  nix.settings.trusted-users = ["nixremote"];
}
