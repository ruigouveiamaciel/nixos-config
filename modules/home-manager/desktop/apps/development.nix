{
  pkgs,
  lib,
  options,
  ...
}: {
  config = lib.mkMerge (
    [
      {
        home.packages = with pkgs; [
          meld
          wireshark
        ];
      }
    ]
    ++ (lib.optional (options.home ? "persistence") {
      home.persistence."/persist" = {
        directories = [
          # {
          #   directory = "";
          #   mode = "0700";
          # }
        ];
      };
    })
  );
}
