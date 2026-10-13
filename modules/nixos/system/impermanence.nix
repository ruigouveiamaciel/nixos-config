{
  inputs,
  lib,
  options,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  config = lib.mkMerge ([
    {
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
          {
            directory = "/root/.cache/nix";
            user = "root";
            group = "root";
            mode = "0700";
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
    ]
    ++ (lib.optional (options ? "home-manager") {
      home-manager.sharedModules = [
        {
          home.persistence."/persist".directories = [
            {
              directory = ".cache/nix";
              mode = "0700";
            }
          ];
        }
      ];
    }));
}
