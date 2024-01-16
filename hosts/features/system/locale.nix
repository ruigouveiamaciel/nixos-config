{lib, ...}: {
  i18n = {
    defaultLocale = lib.mkDefault "en_IE.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = lib.mkDefault "pt_PT.UTF-8";
      LC_IDENTIFICATION = lib.mkDefault "pt_PT.UTF-8";
      LC_MEASUREMENT = lib.mkDefault "pt_PT.UTF-8";
      LC_MONETARY = lib.mkDefault "pt_PT.UTF-8";
      LC_NAME = lib.mkDefault "pt_PT.UTF-8";
      LC_NUMERIC = lib.mkDefault "pt_PT.UTF-8";
      LC_PAPER = lib.mkDefault "pt_PT.UTF-8";
      LC_TELEPHONE = lib.mkDefault "pt_PT.UTF-8";
      LC_TIME = lib.mkDefault "pt_PT.UTF-8";
    };
  };

  time.timeZone = lib.mkDefault "Europe/Lisbon";

  console.keyMap = lib.mkDefault "pt-latin1";

  services.xserver = {
    layout = lib.mkDefault "pt";
    xkbVariant = lib.mkDefault "";
  };
}
