{
  pkgs,
  lib,
  options,
  inputs,
  ...
}: {
  config = lib.mkMerge ([
      {
        home = {
          packages = [
            inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];

          sessionVariables = {
            PI_PING_COMMAND = "pw-play /run/current-system/sw/share/sounds/freedesktop/stereo/service-login.oga";
            PI_PING_DONE_COMMAND = "pw-play /run/current-system/sw/share/sounds/freedesktop/stereo/service-logout.oga";
          };
        };

        # Copy (not symlink) so files can be edited in place;
        # re-applied on every home-manager activation.
        home.activation.copyPiAgentFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
          mkdir -p "$HOME/.pi/agent/extensions" "$HOME/.pi/agent/utils"
          cp -r --no-preserve=mode "${./extensions}/." "$HOME/.pi/agent/extensions/"
          cp -r --no-preserve=mode "${./utils}/." "$HOME/.pi/agent/utils/"
          chmod -R u+w "$HOME/.pi/agent/extensions" "$HOME/.pi/agent/utils"
        '';

        programs.fish.loginShellInit = ''
          if set -q SSH_CONNECTION
            set -e PI_PING_COMMAND
            set -e PI_PING_DONE_COMMAND
          end
        '';
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence = {
        "/persist" = {
          directories = [
            {
              directory = ".pi";
              mode = "0700";
            }
          ];
        };
      };
    }));
}
