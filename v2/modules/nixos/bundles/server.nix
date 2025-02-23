_: {
  config = {
    myNixOS = {
      networking = {
        openssh.enable = true;
        cloudflared.enable = true;
      };
    };
  };
}
