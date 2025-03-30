{
  pkgs,
  config,
  ...
}: {
  services.ttyd = {
    enable = true;
    writeable = true;
    entrypoint = ["${pkgs.shadow}/bin/login" "-f" "rui"];
    clientOptions = {
      fontSize = "16";
      fontFamily = "ComicShannsMono Nerd Font Mono,Consolas,Liberation Mono,Menlo,Courier,monospace";
      fontWeight = "400";
      fontWeightBold = "700";
      cursorBlink = "true";
      theme = builtins.toJSON {
        black = "#494d64";
        red = "#ed8796";
        green = "#a6da95";
        yellow = "#eed49f";
        blue = "#8aadf4";
        magenta = "#f5bde6";
        cyan = "#8bd5ca";
        white = "#b8c0e0";
        brightBlack = "#5b6078";
        brightRed = "#ed8796";
        brightGreen = "#a6da95";
        brightYellow = "#eed49f";
        brightBlue = "#8aadf4";
        brightMagenta = "#f5bde6";
        brightCyan = "#8bd5ca";
        brightWhite = "#a5adcb";
        background = "#24273a";
        foreground = "#cad3f5";
        cursor = "#f4dbd6";
      };
    };
  };

  services.nginx = {
    enable = true;
    additionalModules = with pkgs.nginxModules; [subsFilter];
    recommendedOptimisation = true;
    virtualHosts.ttyd = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8080;
        }
      ];
      locations = {
        "/" = {
          proxyPass = "http://localhost:${builtins.toString config.services.ttyd.port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_set_header Accept-Encoding "";
            subs_filter_types text/html;
            subs_filter '</head>' '<link rel="stylesheet" href="https://mshaugh.github.io/nerdfont-webfonts/build/comicshannsmono.css"></head>';
          '';
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = builtins.map (x: x.port) config.services.nginx.virtualHosts.ttyd.listen;
}
