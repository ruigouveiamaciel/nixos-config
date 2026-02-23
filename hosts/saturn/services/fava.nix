{
  config,
  pkgs,
  ...
}: let
  serviceName = "fava";
  serviceId = 1015;
in {
  virtualisation.oci-containers.containers = {
    "${serviceName}" = {
      autoStart = true;
      image = "${serviceName}:latest";
      imageFile = pkgs.dockerTools.buildImage {
        name = "${serviceName}";
        tag = "latest";

        copyToRoot = pkgs.buildEnv {
          name = "${serviceName}-image-root";
          paths = with pkgs; [fava];
          pathsToLink = ["/bin"];
        };

        runAsRoot = ''
          mkdir -p /data
        '';

        config = {
          Cmd = ["fava" "--host=0.0.0.0" "/data/ledger.beancount"];
          WorkingDir = "/data";
          Volumes = {
            "/data" = {};
          };
          ExposedPorts = {
            "5000/tcp" = {};
          };
        };
      };
      podman = {
        sdnotify = "conmon";
        user = serviceName;
      };
      extraOptions = [
        "--cap-drop=ALL"
      ];
      ports = [
        "10.0.50.42:1601:5000/tcp"
      ];
      volumes = [
        "/persist/services/${serviceName}/data:/data:U"
      ];
    };
  };

  users.groups."${serviceName}".gid = serviceId;
  users.users."${serviceName}" = {
    isNormalUser = true;
    linger = true;
    packages = [config.virtualisation.podman.package];
    uid = serviceId;
    group = serviceName;
    home = "/var/lib/${serviceName}";
    createHome = true;
    subUidRanges = [
      {
        count = 65536;
        startUid = serviceId * 100000;
      }
    ];
    subGidRanges = [
      {
        count = 65536;
        startGid = serviceId * 100000;
      }
    ];
  };

  networking.firewall.interfaces.enp90s0.allowedTCPPorts = [
    1601
  ];

  boot.postBootCommands = let
    uid = builtins.toString config.users.users."${serviceName}".uid;
    gid = builtins.toString config.users.groups."${serviceName}".gid;
  in ''
    mkdir -p /persist/services/${serviceName}/data
    chown ${uid}:${gid} -R /persist/services/${serviceName}
    chmod 750 -R /persist/services/${serviceName}
  '';
}
