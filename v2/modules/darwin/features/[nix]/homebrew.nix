_: {
  config = {
    homebrew = {
      enable = true;
      caskArgs = {
        #require_sha = false;
      };
      onActivation.cleanup = "uninstall";
    };
  };
}
