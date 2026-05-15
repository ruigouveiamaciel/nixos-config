{
  nix = {
    distributedBuilds = true;

    buildMachines = [
      {
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
