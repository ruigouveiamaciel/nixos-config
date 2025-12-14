{
  lib,
  options,
  ...
}: {
  config = lib.mkMerge ([
      rec {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks = {
            jupiter = {
              host = "10.0.0.42";
              forwardAgent = true;
            };
            saturn = {
              host = "10.0.50.42";
              forwardAgent = true;
            };
          };
        };

        programs.fish.shellAbbrs = {
          "jupiter" = "ssh rui@${programs.ssh.matchBlocks.jupiter.host}";
          "unlock-jupiter" = "ssh root@${programs.ssh.matchBlocks.jupiter.host} -p 2222";
          "saturn" = "ssh rui@${programs.ssh.matchBlocks.saturn.host}";
          "unlock-saturn" = "ssh root@${programs.ssh.matchBlocks.saturn.host} -p 2222";
        };
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence = {
        "/persist" = {
          files = [
            ".ssh/known_hosts"
          ];
        };
      };
    }));
}
