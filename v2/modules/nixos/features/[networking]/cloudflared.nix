{lib, ...}: {
  options = with lib; {
    image = mkOption {
      type = types.str;
      default = "cloudflare/cloudflared@sha256:6e2df069aaf5a8c0bf304b674ff31c0ed07c974534b4303a8c6e57d93c6c9224";
    };
  };
}
