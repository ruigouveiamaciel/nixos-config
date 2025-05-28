{
  lib,
  modulesPath,
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    (modulesPath + "/profiles/minimal.nix")
    inputs.nixos-generators.nixosModules.all-formats
  ];

  proxmoxLXC = {
    enable = true;
    manageNetwork = false;
    privileged = false;
    manageHostName = false;
  };

  myNixOS = {
    locales.pt-pt.enable = true;
    networking.openssh.enable = true;
    security.disable-lecture.enable = true;
    nix = {
      nix-settings.enable = true;
      sops.enable = true;
    };
    users.authorized-keys.enable = true;
  };

  sops.useTmpfs = !config.proxmoxLXC.privileged;
  time.timeZone = "Etc/UTC";

  # Allow ssh into root
  users.users.root.openssh.authorizedKeys.keys = config.myNixOS.users.authorized-keys.users.rui;
  services.openssh = {
    startWhenNeeded = true;
    settings.PermitRootLogin = lib.mkForce "yes";
  };

  networking = {
    # These services are usually behind VPNs that don't support IPv6 anyways
    enableIPv6 = lib.mkDefault false;

    # Default firewall rules prevents DNS from working in podman networks
    firewall = {
      enable = true;
      interfaces."podman+" = {
        allowedUDPPorts = [53];
        allowedTCPPorts = [53];
      };
    };
  };

  # OOMD causes issues on low-memory scenarios
  systemd.oomd.enable = false;

  systemd.services =
    lib.attrsets.mapAttrs' (_: {serviceName, ...}:
      lib.attrsets.nameValuePair serviceName {
        after = lib.mkIf (config.virtualisation.oci-containers.backend == "podman") ["create-internal-podman-network.service"];
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 60;
        };
      })
    config.virtualisation.oci-containers.containers
    // {
      create-internal-podman-network = lib.mkIf (config.virtualisation.oci-containers.backend == "podman") {
        after = ["podman.service"];
        wantedBy = ["multi-user.target"];
        script = ''
          ${pkgs.podman}/bin/podman network exists podman-internal || \
          ${pkgs.podman}/bin/podman network create --internal podman-internal
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";
}
