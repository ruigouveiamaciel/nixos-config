{...}: {
  config = {
    services.dnscrypt-proxy2 = {
      settings = {
        anonymized_dns = {
          skip_incompatible = true;
          routes = [
            {
              server_name = "*";
              via = ["anon-cs-berlin"];
            }
          ];
        };
      };
    };
  };
}
