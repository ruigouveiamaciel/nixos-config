{
  options,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge ([
      {
        environment = {
          systemPackages = with pkgs; [
            wireguard-tools
          ];
          etc."NetworkManager/dispatcher.d/70-wg-quick" = {
            mode = "0755";
            source = pkgs.writeShellScript "nm-dispatcher-wg-quick" ''
              set -e

              exec 2> >(logger -t "nm-wg-dispatch[$$]")
              logger -t nm-wg-dispatch "iface=$1 event=$2 ssid=''${CONNECTION_ID:-}"

              action="$2"
              ssid="''${CONNECTION_ID:-}"
              wg_iface="openwrt"
              wg_bin="${lib.getExe' pkgs.wireguard-tools "wg-quick"}"

              export PATH="${pkgs.wireguard-tools}/bin:$PATH"

              is_up() {
                ip link show "$wg_iface" &>/dev/null
              }

              start_tun() {
                if out=$("$wg_bin" up "$wg_iface" 2>&1); then
                  logger -t nm-wg-dispatch "tunnel up"
                else
                  logger -t nm-wg-dispatch "tunnel FAILED rc=$?: $out"
                fi
              }

              stop_tun() {
                if out=$("$wg_bin" down "$wg_iface" 2>&1); then
                  logger -t nm-wg-dispatch "tunnel down"
                else
                  logger -t nm-wg-dispatch "tunnel down (rc=$?): $out"
                fi
              }

              case "$ssid" in
                "$wg_iface")
                  exit 0
                  ;;
                "You Shall Not Lag")
                  if is_up; then
                    logger -t nm-wg-dispatch "stopping tunnel"
                    stop_tun & disown
                  fi
                  ;;
                *)
                  if is_up; then
                    stop_tun 2>/dev/null || true
                  fi
                  if [[ "$action" == "up" ]]; then
                    logger -t nm-wg-dispatch "starting tunnel"
                    start_tun & disown
                  fi
                  ;;
              esac
            '';
          };
        };
      }
    ]
    ++ (lib.optional (options.environment ? "persistence") {
      environment.persistence."/persist" = {
        directories = [
          {
            directory = "/etc/wireguard";
            user = "root";
            group = "root";
            mode = "0700";
          }
        ];
      };
    }));
}
