{
  pkgs,
  lib,
  options,
  inputs,
  ...
}: let
  jq = lib.getExe pkgs.jq;
in {
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
          mkdir -p "$HOME/.pi/agent/extensions" "$HOME/.pi/agent/utils" "$HOME/.pi/agent/prompts"
          cp -r --no-preserve=mode "${./extensions}/." "$HOME/.pi/agent/extensions/"
          cp -r --no-preserve=mode "${./utils}/." "$HOME/.pi/agent/utils/"
          cp -r --no-preserve=mode "${./prompts}/." "$HOME/.pi/agent/prompts/"
          chmod -R u+w "$HOME/.pi/agent/extensions" "$HOME/.pi/agent/utils" "$HOME/.pi/agent/prompts"
          install -m 644 "${./mcp.json}" "$HOME/.pi/agent/mcp.json"

          (
            piSettings="$HOME/.pi/agent/settings.json"
            if [[ ! -f "$piSettings" ]]; then
              printf '{}' > "$piSettings"
            fi
            ${jq} '. * {
              defaultProvider: "opencode-go",
              defaultModel: "glm-5.3-flash",
              enabledModels: [
                "opencode-go/glm-5.3",
                "opencode-go/glm-5.3-flash",
                "opencode-go/qwen3.8-flash",
                "opencode-go/gpt-6-luna",
                "opencode-go/deepseek-v4.1-flash",
                "opencode-go/deepseek-v4-pro",
                "opencode-go/claude-haiku-5-5"
              ]
            }' "$piSettings" > "$piSettings.tmp"
            mv "$piSettings.tmp" "$piSettings"
            chmod 644 "$piSettings"
          )
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
