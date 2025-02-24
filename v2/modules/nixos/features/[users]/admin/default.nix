{config, ...}: {
  config = {
    myNixOS = {
      users = {
        enable = true;
        authorized-keys.enable = true;
        users = {
          admin = {
            authorizedKeys = config.myNixOS.users.authorized-keys.users.rui;
            extraGroups = ["wheel"];
          };
        };
      };
    };

    security.sudo.extraRules = [
      {
        users = ["admin"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
