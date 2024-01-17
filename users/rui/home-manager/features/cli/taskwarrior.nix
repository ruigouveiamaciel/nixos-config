{pkgs, config, secrets, ...}:{
  home.packages = with pkgs; [
    taskwarrior
    tasksh
  ];

  home.persistence."/nix/backup${config.home.homeDirectory}" = {
    directories = [
      ".task"
    ];
  };
  
  # TODO: Change trust to strict once server is properly setup
  # TODO: Update uuid once server is properly setup
  # TODO: Update server address and port
  home.file.".taskrc".text = ''
    data.location=${config.home.homeDirectory}/.task
    taskd.ca=${secrets.rui-taskwarrior-ca-cert}
    taskd.key=${secrets.rui-taskwarrior-key}
    taskd.certificate=${secrets.rui-taskwarrior-cert}
    taskd.server=192.168.1.76:49591
    taskd.credentials=family/rui/05858de0-6d53-4b3e-bf19-654d1f99a937
    taskd.trust=ignore hostname
    news.version=2.6.0
  '';
}