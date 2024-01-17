{pkgs, config, ...}:{
  home.packages = with pkgs; [
    taskwarrior
    tasksh
  ];

  home.persistence."/nix/backup${config.home.homeDirectory}" = {
    allowOther = true;
    directories = [
      ".task"
    ];
  };
  
  home.file.".taskrc".text = ''
    data.location=${config.home.homeDirectory}/.task
    news.version=2.6.0
  '';
}