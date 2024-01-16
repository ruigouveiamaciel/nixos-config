{
  config,
  lib,
  pkgs,
  ...
}: {
  # Wireless secrets stored through sops
  sops.secrets.wireless-passwords = {
    sopsFile = ../../common-secrets.yaml;
    neededForUsers = true;
  };

  networking.networkmanager.enable = false;

  networking.wireless = {
    enable = true;
    fallbackToWPA2 = false;

    # Declarative
    environmentFile = config.sops.secrets.wireless-passwords.path;
    networks = {
      "eduroam" = {
        authProtocols = ["WPA-EAP"];
        auth = ''
          ca_cert="${../../certs/eduroam.crt}"
          password="@EDUROAM_PASSWORD@"
          key_mgmt=WPA-EAP
          eap=PEAP
          identity="ist195671@tecnico.ulisboa.pt"
          phase2="auth=MSCHAPV2"
          anonymous_identity="anonymous@tecnico.ulisboa.pt"
        '';
        priority = 1;
      };
      "BITnet" = {
        psk = "@BITNET_PASSWORD@";
        priority = 3;
      };
      "Vodafone-189646" = {
        psk = "@APARTMENT_PASSWORD@";
        priority = 0;
      };
      "Vodafone-189646-5G" = {
        psk = "@APARTMENT_PASSWORD@";
        priority = 1;
      };
      "Micro-ondas" = {
        psk = "@PARENTS_HOUSE_PASSWORD@";
        priority = 1;
      };
    };

    # Imperative
    allowAuxiliaryImperativeNetworks = true;
    userControlled = {
      enable = true;
      group = "network";
    };
    extraConfig = ''
      update_config=1
    '';
  };

  users.groups.network = {};

  systemd.services.wpa_supplicant.preStart = "touch /etc/wpa_supplicant.conf";
}
