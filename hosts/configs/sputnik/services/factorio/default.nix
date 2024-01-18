{
  pkgs,
  config,
  self,
  lib,
  ...
}: let
  backend = config.virtualisation.oci-containers.backend;
  backendBin = "${pkgs.${backend}}/bin/${backend}";
in {
  virtualisation.oci-containers.containers = {
    factorio-server = {
      image = "factoriotools/factorio@sha256:67324ccad64e6e21b73085abad7e4a33823c6f43b074a55be10f48caf02ed1eb";
      extraOptions = [
        "--network=factorio_network"
      ];
      environmentFiles = [
        config.sops.templates."factorio-secrets.env".path
      ];
      volumes = [
        "/nix/backup/services/factorio/data:/factorio"
        "${config.sops.templates."factorio-settings.json".path}:/factorio/config/server-settings.json"
      ];
      ports = [
        "34000:34197"
      ];
    };
  };

  systemd.services.prepare-factorio-server = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-factorio-server.service"
    ];
    script = ''
      mkdir -p /nix/backup/services/factorio/data
      ${backendBin} network inspect factorio_network >/dev/null 2>&1 || ${backendBin} network create factorio_network
    '';
  };

  networking.firewall.allowedUDPPorts = [
    34000
  ];

  networking.firewall.allowedTCPPorts = [
    34000
  ];

  sops.secrets.factorio-token = {
    sopsFile = ../../secrets.yaml;
  };

  sops.templates."factorio-secrets.env".content = ''
    GENERATE_NEW_SAVE=true
    LOAD_LATEST_SAVE=true
    SAVE_NAME=world
    UPDATE_MODS_ON_START=true
    USERNAME=SmOkEwOw
    PORT=34197
    TOKEN=${config.sops.placeholder.factorio-token}
  '';

  sops.templates."factorio-settings.json".content = ''
    {
      "name": "SmOkEwOw's Public Factorio Server",
      "description": "Feel free to join and mess around",
      "tags": ["vanilla", "public"],

      "_comment_max_players": "Maximum number of players allowed, admins can join even a full server. 0 means unlimited.",
      "max_players": 0,

      "_comment_visibility": ["public: Game will be published on the official Factorio matching server",
                              "lan: Game will be broadcast on LAN"],
      "visibility":
      {
        "public": true,
        "lan": true
      },

      "_comment_credentials": "Your factorio.com login credentials. Required for games with visibility public",
      "username": "SmOkEwOw",
      "password": "",

      "_comment_token": "Authentication token. May be used instead of 'password' above.",
      "token": "${config.sops.placeholder.factorio-token}",

      "game_password": "",

      "_comment_require_user_verification": "When set to true, the server will only allow clients that have a valid Factorio.com account",
      "require_user_verification": true,

      "_comment_max_upload_in_kilobytes_per_second" : "optional, default value is 0. 0 means unlimited.",
      "max_upload_in_kilobytes_per_second": 0,

      "_comment_max_upload_slots" : "optional, default value is 5. 0 means unlimited.",
      "max_upload_slots": 5,

      "_comment_minimum_latency_in_ticks": "optional one tick is 16ms in default speed, default value is 0. 0 means no minimum.",
      "minimum_latency_in_ticks": 0,

      "_comment_max_heartbeats_per_second": "Network tick rate. Maximum rate game updates packets are sent at before bundling them together. Minimum value is 6, maximum value is 240.",
      "max_heartbeats_per_second": 60,

      "_comment_ignore_player_limit_for_returning_players": "Players that played on this map already can join even when the max player limit was reached.",
      "ignore_player_limit_for_returning_players": false,

      "_comment_allow_commands": "possible values are, true, false and admins-only",
      "allow_commands": "admins-only",

      "_comment_autosave_interval": "Autosave interval in minutes",
      "autosave_interval": 10,

      "_comment_autosave_slots": "server autosave slots, it is cycled through when the server autosaves.",
      "autosave_slots": 5,

      "_comment_afk_autokick_interval": "How many minutes until someone is kicked when doing nothing, 0 for never.",
      "afk_autokick_interval": 0,

      "_comment_auto_pause": "Whether should the server be paused when no players are present.",
      "auto_pause": true,

      "only_admins_can_pause_the_game": true,

      "_comment_autosave_only_on_server": "Whether autosaves should be saved only on server or also on all connected clients. Default is true.",
      "autosave_only_on_server": true,

      "_comment_non_blocking_saving": "Highly experimental feature, enable only at your own risk of losing your saves. On UNIX systems, server will fork itself to create an autosave. Autosaving on connected Windows clients will be disabled regardless of autosave_only_on_server option.",
      "non_blocking_saving": true,

      "_comment_segment_sizes": "Long network messages are split into segments that are sent over multiple ticks. Their size depends on the number of peers currently connected. Increasing the segment size will increase upload bandwidth requirement for the server and download bandwidth requirement for clients. This setting only affects server outbound messages. Changing these settings can have a negative impact on connection stability for some clients.",
      "minimum_segment_size": 25,
      "minimum_segment_size_peer_count": 20,
      "maximum_segment_size": 100,
      "maximum_segment_size_peer_count": 10
    }
  '';
}
