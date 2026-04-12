{pkgs, ...}: {
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/DarkestHour/contents/images/2560x1440.jpg";
      enableMiddleClickPaste = false;
    };

    kscreenlocker = {
      autoLock = false;
      lockOnResume = false;
    };

    powerdevil = {
      AC = {
        powerButtonAction = "shutDown";
        autoSuspend.action = "nothing";
        turnOffDisplay.idleTimeout = "never";
        dimDisplay.enable = false;
      };
      battery = {
        powerButtonAction = "shutDown";
        autoSuspend.action = "nothing";
        turnOffDisplay.idleTimeout = "never";
        dimDisplay.enable = false;
      };
      lowBattery = {
        powerButtonAction = "shutDown";
        autoSuspend.action = "nothing";
        turnOffDisplay.idleTimeout = "never";
        dimDisplay.enable = false;
      };
    };

    input.mice = [
      {
        enable = true;
        acceleration = 0;
        accelerationProfile = "none";
        leftHanded = false;
        middleButtonEmulation = false;
        name = "ZSA Technology Labs Voyager";
        naturalScroll = false;
        productId = "1977";
        scrollSpeed = 1;
        vendorId = "3297";
      }
      {
        enable = true;
        acceleration = 0;
        accelerationProfile = "none";
        leftHanded = false;
        middleButtonEmulation = false;
        name = "Logitech USB Receiver";
        naturalScroll = false;
        productId = "c54d";
        scrollSpeed = 1;
        vendorId = "046d";
      }
    ];

    window-rules = [
      {
        description = "Kitty on workspace 1 maximized";
        match = {
          window-class = {
            value = "kitty kitty";
            type = "exact";
          };
        };
        apply = {
          desktops = {
            value = "17fa73e5-92c7-474b-9965-9b281f632d9d";
            apply = "initially";
          };
          maximizehoriz = {
            value = true;
            apply = "initially";
          };
          maximizevert = {
            value = true;
            apply = "initially";
          };
        };
      }
      {
        description = "LibreWolf on workspace 4 maximized";
        match = {
          window-class = {
            value = "librewolf librewolf";
            type = "exact";
          };
        };
        apply = {
          desktops = {
            value = "88d4ecc2-5849-4254-8295-607759b70c25";
            apply = "initially";
          };
          maximizehoriz = {
            value = true;
            apply = "initially";
          };
          maximizevert = {
            value = true;
            apply = "initially";
          };
        };
      }
      {
        description = "Vesktop on workspace 10 maximized";
        match = {
          window-class = {
            value = "electron vesktop";
            type = "exact";
          };
        };
        apply = {
          desktops = {
            value = "fe00c54d-8792-4c79-b8c2-eea7fd033356";
            apply = "initially";
          };
          maximizehoriz = {
            value = true;
            apply = "initially";
          };
          maximizevert = {
            value = true;
            apply = "initially";
          };
        };
      }
      {
        description = "Steam on workspace 6 maximized";
        match = {
          window-class = {
            value = "steamwebhelper steam";
            type = "exact";
          };
        };
        apply = {
          desktops = {
            value = "eacd5a71-392c-472a-8c83-81d536176454";
            apply = "initially";
          };
          maximizehoriz = {
            value = true;
            apply = "initially";
          };
          maximizevert = {
            value = true;
            apply = "initially";
          };
        };
      }
    ];

    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      kwinrc = {
        "Effect-overview"."BorderActivate".value = 9;
        "Desktops" = {
          "Number".value = 10;
          "Id_1".value = "17fa73e5-92c7-474b-9965-9b281f632d9d";
          "Id_2".value = "da5ed6bd-9b1d-4a76-adbb-f1efe56e5718";
          "Id_3".value = "bc0b02bd-037e-4a26-a0b8-470db1b9818c";
          "Id_4".value = "88d4ecc2-5849-4254-8295-607759b70c25";
          "Id_5".value = "27f88eb5-e254-4a91-85c0-7faf617b2c2f";
          "Id_6".value = "eacd5a71-392c-472a-8c83-81d536176454";
          "Id_7".value = "4961db74-0107-40d5-a78d-43da653fc331";
          "Id_8".value = "f404a3ae-ec9c-4465-9ffc-ad015b8e9368";
          "Id_9".value = "66f0dd2f-90c8-49c9-a105-49ad53537bf1";
          "Id_10".value = "fe00c54d-8792-4c79-b8c2-eea7fd033356";
        };
      };
      kdeglobals = {
        "KDE"."AnimationDurationFactor".value = 0;
        "Shortcuts" = {
          "Copy".value = "Ctrl+C; Meta+C";
          "Cut".value = "Ctrl+X; Meta+X";
          "Paste".value = "Ctrl+V; Meta+V";
        };
      };
    };

    shortcuts = {
      "services/org.kde.krunner.desktop" = {
        "RunClipboard" = "none";
        "_launch" = "Meta+Space";
      };
      "services/org.kde.kscreen.desktop" = {
        "ShowOSD" = "none";
      };
      "services/org.kde.plasma-systemmonitor.desktop" = {
        "_launch" = "Ctrl+Shift+Esc";
      };
      "services/org.kde.konsole.desktop" = {
        "_launch" = "none";
      };
      "services/org.kde.plasma.emojier.desktop" = {
        "_launch" = "none";
      };
      plasmashell = {
        "activate application launcher" = "none";
        "activate task manager entry 1" = "none";
        "activate task manager entry 2" = "none";
        "activate task manager entry 3" = "none";
        "activate task manager entry 4" = "none";
        "activate task manager entry 5" = "none";
        "activate task manager entry 6" = "none";
        "activate task manager entry 7" = "none";
        "activate task manager entry 8" = "none";
        "activate task manager entry 9" = "none";
        "activate task manager entry 10" = "none";
        "clipboard_action" = "none";
        "cycle-panels" = "none";
        "show-on-mouse-pos" = "none";
        "manage activities" = "none";
        "next activity" = "none";
        "previous activity" = "none";
        "show dashboard" = "none";
      };
      "org_kde_powerdevil" = {
        "powerProfile" = "none";
      };
      kwin = {
        "view_zoom_in" = "none";
        "view_zoom_out" = "none";
        "view_actual_size" = "none";
        "disableInputCapture" = "none";
        "Window to Next Screen" = "none";
        "Window to Previous Screen" = "none";
        "Window Quick Tile Top" = "none";
        "Window Quick Tile Right" = "none";
        "Window Quick Tile Left" = "none";
        "Window Quick Tile Bottom" = "none";
        "Window Operations Menu" = "none";
        "Window One Desktop to the Right" = "none";
        "Window One Desktop to the Left" = "none";
        "Window One Desktop Up" = "none";
        "Window One Desktop Down" = "none";
        "Window Minimize" = "none";
        "Window Maximize" = "none";
        "Walk Through Windows of Current Application" = "none";
        "Walk Through Windows of Current Application (Reverse)" = "none";
        "Walk Through Windows" = "Alt+Tab";
        "Walk Through Windows (Reverse)" = "none";
        "Activate Window Demanding Attention" = "none";
        "Edit Tiles" = "none";
        "Expose" = "none";
        "ExposeAll" = "none";
        "ExposeClass" = "none";
        "ExposeClassCurrentDesktop" = "none";
        "Grid View" = "none";
        "Kill Window" = "Meta+W";
        "MoveMouseToCenter" = "none";
        "MoveMouseToFocus" = "none";
        "Overview" = "none";
        "Show Desktop" = "Meta+D";
        "Switch One Desktop Down" = "none";
        "Switch One Desktop Up" = "none";
        "Switch One Desktop to the Right" = "none";
        "Switch One Desktop to the Left" = "none";
        "Switch Window Down" = "none";
        "Switch Window Up" = "none";
        "Switch Window Left" = "none";
        "Switch Window Right" = "none";
        "Window to Desktop 1" = "Meta+!";
        "Window to Desktop 2" = "Meta+\"";
        "Window to Desktop 3" = "Meta+#";
        "Window to Desktop 4" = "Meta+$";
        "Window to Desktop 5" = "Meta+%";
        "Window to Desktop 6" = "Meta+&";
        "Window to Desktop 7" = "Meta+/";
        "Window to Desktop 8" = "Meta+(";
        "Window to Desktop 9" = "Meta+)";
        "Window to Desktop 10" = "Meta+=";
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Switch to Desktop 5" = "Meta+5";
        "Switch to Desktop 6" = "Meta+6";
        "Switch to Desktop 7" = "Meta+7";
        "Switch to Desktop 8" = "Meta+8";
        "Switch to Desktop 9" = "Meta+9";
        "Switch to Desktop 10" = "Meta+0";
      };
      "KDE Keyboard Layout Switcher" = {
        "Switch to Last-Used Keyboard Layout" = "none";
        "Switch to Next Keyboard Layout" = "none";
      };
      kaccess = {
        "Toggle Screen Reader On and Off" = "none";
      };
      ksmserver = {
        "Lock Session" = "none";
        "Log Out" = "none";
      };
    };

    panels = [
      {
        location = "bottom";
        widgets = [
          {
            kickoff = {
              sortAlphabetically = true;
            };
          }
          {
            pager = {};
          }
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:kitty.desktop"
                "applications:librewolf.desktop"
                "applications:vesktop.desktop"
                "applications:steam.desktop"
              ];
              behavior = {
                middleClickAction = "newInstance";
                minimizeActiveTaskOnClick = false;
                showTasks = {
                  onlyInCurrentScreen = false;
                  onlyInCurrentDesktop = false;
                  onlyInCurrentActivity = false;
                  onlyMinimized = false;
                };
              };
              appearance.indicateAudioStreams = false;
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
              hidden = [];
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "sunday";
              time.format = "24h";
            };
          }
        ];
      }
    ];
  };
}
