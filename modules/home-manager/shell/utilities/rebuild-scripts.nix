{pkgs, ...}: {
  home.packages = let
    mkScript = {
      name,
      action,
      useSudo ? true,
    }:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          nixos-rebuild
          nix-output-monitor
          hostname
        ];
        text = ''
          set -exo pipefail

          config_dir="$HOME/projects/nixos-config"
          host="$(hostname -s)"

          if [[ ! -f "$config_dir/flake.nix" ]]; then
            echo "error: $config_dir/flake.nix not found" >&2
            exit 1
          fi

          cd "$config_dir"

          ${if useSudo then "sudo_cmd=(sudo)" else "sudo_cmd=()"}
          if [[ -t 0 && -t 1 ]]; then
            "''${sudo_cmd[@]}" nixos-rebuild ${action} --log-format internal-json -v --flake ".#$host" 2>&1 | nom --json
          else
            "''${sudo_cmd[@]}" nixos-rebuild ${action} --flake ".#$host" 2>&1 | tail -n 200
          fi
        '';
      };
  in [
    (mkScript {
      name = "build";
      action = "build";
      useSudo = false;
    })
    (mkScript {
      name = "rebuild";
      action = "switch";
    })
  ];
}
