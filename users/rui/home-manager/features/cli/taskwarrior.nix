{
  pkgs,
  config,
  secrets,
  ...
}: {
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
    taskd.server=taskserver.maciel.sh:49591
    taskd.credentials=family/rui/9e28e318-5a64-4058-9057-2382deabadb0
    taskd.trust=strict
    news.version=2.6.0
  '';
}
