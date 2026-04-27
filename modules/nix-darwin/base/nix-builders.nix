# Disable on the fly with: NIX_BUILD_HOOK= nix build ...
{
  nix = {
    distributedBuilds = true;

    buildMachines = [
      {
        # saturn — addressed by IP because the hostname doesn't resolve
        # in every network we use.
        hostName = "10.0.50.42";
        sshUser = "nixremote";
        sshKey = "/var/root/.ssh/id_ed25519_nixremote";
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
