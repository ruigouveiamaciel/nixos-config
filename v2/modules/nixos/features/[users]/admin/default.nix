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
  };
}
