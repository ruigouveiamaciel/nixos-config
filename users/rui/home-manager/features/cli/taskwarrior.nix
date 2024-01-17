{pkgs, config, secrets, ...}:{
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
  
  # TODO: Change trust to strict once server is properly setup
  # TODO: Update uuid once server is properly setup
  home.file.".taskrc".text = ''
    data.location=${config.home.homeDirectory}/.task
    taskd.ca=${secrets.rui-taskwarrior-ca-cert}
    taskd.key=${secrets.rui-taskwarrior-key}
    taskd.certificate=${secrets.rui-taskwarrior-cert}
    taskd.server=192.168.1.76:53589
    taskd.credentials=family/rui/7eb7c141-50cf-4d22-be9d-bc093ddb1c67
    taskd.trust=ignore hostname
    news.version=2.6.0
  '';
}