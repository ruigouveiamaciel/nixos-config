# Disable on the fly with: NIX_BUILD_HOOK= nix build ...
{
  nix = {
    distributedBuilds = true;

    buildMachines = [
      {
        hostName = "saturn";
        sshUser = "nixremote";
        sshKey = "/Users/ruimaciel/.ssh/id_ed25519";
        protocol = "ssh-ng";
        systems = ["x86_64-linux" "aarch64-linux"];
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      }
    ];

    settings = {
      builders-use-substitutes = true;
    };
  };
}
