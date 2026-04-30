{pkgs, ...}: {
  home.packages = with pkgs; [
    jq
    jless
    jsonschema-cli
  ];
}
