{
  lib,
  config,
  ...
}: {
  config = {
    # TODO: Fix this

    # networking.hosts =
    #   lib.attrsets.foldlAttrs (
    #     name: acc: value: let
    #       current = lib.attrByPath [value.ip] [] acc;
    #     in
    #       acc // {"${value.ip}" = current ++ [name];}
    #   ) {}
    #   config.myConstants.homelab;
  };
}
