{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  fileSystems."/persist".neededForBoot = true;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      {
        directory = "/var/log";
        user = "root";
        group = "root";
        mode = "0755";
      }
      {
        directory = "/var/lib/bluetooth";
        user = "root";
        group = "root";
        mode = "0700";
      }
      {
        directory = "/var/lib/nixos";
        user = "root";
        group = "root";
        mode = "0755";
      }
      {
        directory = "/var/lib/systemd/coredump";
        user = "root";
        group = "root";
        mode = "0755";
      }
      {
        directory = "/var/lib/systemd/timers";
        user = "root";
        group = "root";
        mode = "0755";
      }
      {
        directory = "/var/lib/containers";
        user = "root";
        group = "root";
        mode = "0755";
      }
    ];
    files = [
      {
        file = "/etc/machine-id";
        parentDirectory = {
          user = "root";
          group = "root";
          mode = "0755";
        };
      }
    ];
  };
}
