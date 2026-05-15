{config, ...}: {
  programs.gpg = {
    enable = true;
    settings.trust-model = "tofu+pgp";
    publicKeys = [
      {
        source = config.myConstants.users.smokewow.pgp;
        trust = 5;
      }
    ];
  };
}
