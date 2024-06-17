{
  services = {
    logind = {
      lidSwitch = "ignore";
      lidSwitchExternalPower = "ignore";
      lidSwitchDocked = "ignore";
    };

    power-profiles-daemon.enable = false;

    tlp = {
      enable = true;
      settings = {
        SOUND_POWER_SAVE_ON_AC = 1;
        SOUND_POWER_SAVE_ON_BAT = 1;

        DISK_DEVICES = "nvme0n1";
        DISK_APM_LEVEL_ON_AC = "254 254";
        DISK_APM_LEVEL_ON_BAT = "128 128";
        AHCI_RUNTIME_PM_ON_AC = "on";
        AHCI_RUNTIME_PM_ON_BAT = "auto";

        DISK_IDLE_SECS_ON_AC = 0;
        DISK_IDLE_SECS_ON_BAT = 2;

        MAX_LOST_WORK_SECS_ON_AC = 15;
        MAX_LOST_WORK_SECS_ON_BAT = 60;

        INTEL_GPU_MIN_FREQ_ON_AC = 100;
        INTEL_GPU_MIN_FREQ_ON_BAT = 100;
        INTEL_GPU_MAX_FREQ_ON_AC = 1250;
        INTEL_GPU_MAX_FREQ_ON_BAT = 1250;
        INTEL_GPU_BOOST_FREQ_ON_AC = 1250;
        INTEL_GPU_BOOST_FREQ_ON_BAT = 1250;

        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        WOL_DISABLE = "Y";

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";

        CPU_DRIVER_OPMODE_ON_AC = "active";
        CPU_DRIVER_OPMODE_ON_BAT = "active";

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 100;

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;

        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 1;
      };
    };
  };
}
