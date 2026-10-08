{
  # Allow sudo only via an authorized ssh agent
  security = {
    pam = {
      rssh.enable = true;
      services.sudo = {
        rssh = true;
        unixAuth = false;
      };
    };
  };
}
