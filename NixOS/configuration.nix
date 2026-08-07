{ config, pkgs, inputs, pkgs-unstable, lib, ... }:

let
  desktopUser = builtins.head (builtins.attrNames config.home-manager.users);

  sddmAstronautHyprlandKathTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "sddm-astronaut-theme-hyprland-kath";
    version = "1";
    dontUnpack = true;

    installPhase = ''
      mkdir -p "$out/share/sddm/themes"
      cp -r "${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme" "$out/share/sddm/themes/"
      mv "$out/share/sddm/themes/sddm-astronaut-theme" "$out/share/sddm/themes/sddm-astronaut-theme-hyprland-kath"
      chmod -R u+w "$out/share/sddm/themes/sddm-astronaut-theme-hyprland-kath"
      substituteInPlace "$out/share/sddm/themes/sddm-astronaut-theme-hyprland-kath/metadata.desktop" \
        --replace "ConfigFile=Themes/astronaut.conf" "ConfigFile=Themes/black_hole.conf"
    '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
    timeout = 5;
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
      graceful = true;
      extraInstallCommands = ''
        bootctl set-timeout 5
      '';
    };
  };
  boot.kernelPackages = pkgs.linuxPackages;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "uinput"
    "xpad"
  ];
  # Blacklist Intel DTT/thermal drivers to fix constant high fan speeds (5400+ RPM) on Huawei MateBook 14s (2022).
  # This returns thermal/fan control to the BIOS, which behaves much quieter.
  boot.blacklistedKernelModules = [
    "int3400_thermal"
    "int3403_thermal"
    "int340x_thermal_zone"
    "processor_thermal_device"
    "processor_thermal_device_pci"
    "processor_thermal_soc_slider"
  ];
  boot.extraModulePackages = [ ];
  boot.resumeDevice = "/dev/disk/by-uuid/c95c8d22-0de2-4e0d-a8f4-d0951c736c83";
  boot.plymouth = {
    enable = true;
    # themePackages = [ pkgs.adi1090x-plymouth-themes ];
    # theme = "connect";
    theme = "bgrt";
  };
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=0"
    "udev.log_priority=0"
  ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "docker0" ];

  # LocalSend port exception
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

  services.resolved.enable = true;
  services.netbird.enable = true;

  # AmneziaVPN
  systemd.services.amnezia-vpn = {
    description = "AmneziaVPN Background Service";
    after = [ "network.target" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs-unstable.amnezia-vpn}/bin/AmneziaVPN-service";
      Restart = "always";
      RestartSec = 5;
      User = "root";
      Group = "root";
    };
  };

  # Power profiles
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
  };
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30min";
  };

  # Use power-profiles-daemon for explicit manual profile switching.
  # TLP conflicts with this workflow by reapplying AC/BAT policies.
  services.power-profiles-daemon.enable = true;

  systemd.services.low-battery-monitor = {
    description = "Notify on low battery and hibernate before power loss";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-logind.service" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
    };
    script = ''
      # Constants
      USER_NAME=${lib.escapeShellArg desktopUser}
      USER_UID=$(${pkgs.coreutils}/bin/id -u "$USER_NAME")
      POLL_INTERVAL_SECONDS=60
      FIRST_WARNING_PERCENT=15
      CRITICAL_WARNING_PERCENT=5
      HIBERNATE_PERCENT=2
      HIBERNATE_DELAY_SECONDS=5
      STATE_FILE=/run/low-battery-monitor.state

      notify_user() {
        urgency=$1
        summary=$2
        body=$3
        runtime_dir="/run/user/$USER_UID"
        bus="unix:path=$runtime_dir/bus"

        if [ -S "$runtime_dir/bus" ]; then
          ${pkgs.util-linux}/bin/runuser -u "$USER_NAME" -- \
            env XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="$bus" \
            ${pkgs.libnotify}/bin/notify-send -u "$urgency" "$summary" "$body" || true
        fi
      }

      while true; do
        mains_online=0
        battery_capacity=
        battery_status=

        for ps in /sys/class/power_supply/*; do
          [ -e "$ps" ] || continue

          if [ -f "$ps/type" ] && [ -f "$ps/online" ] && [ "$(cat "$ps/type")" = "Mains" ]; then
            if [ "$(cat "$ps/online")" = "1" ]; then
              mains_online=1
            fi
          fi

          if [ -f "$ps/type" ] && [ -f "$ps/capacity" ] && [ "$(cat "$ps/type")" = "Battery" ]; then
            status=Unknown
            [ -f "$ps/status" ] && status=$(cat "$ps/status")

            if [ -z "$battery_capacity" ] || [ "$status" = "Discharging" ]; then
              battery_capacity=$(cat "$ps/capacity")
              battery_status=$status
            fi
          fi
        done

        if [ -z "$battery_capacity" ]; then
          sleep "$POLL_INTERVAL_SECONDS"
          continue
        fi

        case "$battery_capacity" in
          ""|*[!0-9]*)
            sleep "$POLL_INTERVAL_SECONDS"
            continue
            ;;
        esac

        if [ "$mains_online" = "1" ] || [ "$battery_status" != "Discharging" ]; then
          printf '%s\n' reset > "$STATE_FILE"
          sleep "$POLL_INTERVAL_SECONDS"
          continue
        fi

        last_state=
        [ -r "$STATE_FILE" ] && last_state=$(cat "$STATE_FILE")

        if [ "$battery_capacity" -le "$HIBERNATE_PERCENT" ]; then
          notify_user critical "Battery critical" "Battery is at $battery_capacity%. Hibernating now."
          printf '%s\n' hibernate > "$STATE_FILE"
          sleep "$HIBERNATE_DELAY_SECONDS"
          ${pkgs.systemd}/bin/systemctl hibernate
        elif [ "$battery_capacity" -le "$CRITICAL_WARNING_PERCENT" ] && [ "$last_state" != "$CRITICAL_WARNING_PERCENT" ]; then
          notify_user critical "Battery low" "Battery is at $battery_capacity%. Hibernation starts at $HIBERNATE_PERCENT%."
          printf '%s\n' "$CRITICAL_WARNING_PERCENT" > "$STATE_FILE"
        elif [ "$battery_capacity" -le "$FIRST_WARNING_PERCENT" ] && [ "$last_state" != "$FIRST_WARNING_PERCENT" ] && [ "$last_state" != "$CRITICAL_WARNING_PERCENT" ]; then
          notify_user normal "Battery low" "Battery is at $battery_capacity%. Plug in the charger."
          printf '%s\n' "$FIRST_WARNING_PERCENT" > "$STATE_FILE"
        fi

        sleep "$POLL_INTERVAL_SECONDS"
      done
    '';
  };

  # Throne Settings
  security.wrappers.Throne = {
    source = "${pkgs-unstable.throne}/bin/Throne";
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin,cap_net_bind_service+ep";
  };

  # Throne talks to systemd-resolved for per-link DNS and routing changes.
  # Allow the full resolve1 action namespace for alex to avoid repeated
  # polkit prompts on connect/disconnect and profile stop.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.user == "${desktopUser}" &&
        action.id.indexOf("org.freedesktop.resolve1.") === 0
      ) {
        return polkit.Result.YES;
      }
    });
  '';

  # Localization
  time.timeZone = "Europe/Moscow";
  time.hardwareClockInLocalTime = false;
  services.timesyncd.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
  };
  console.keyMap = "us";

  environment.localBinInPath = true;

  # User account
  users.users.${desktopUser} = {
    isNormalUser = true;
    description = "Alexander";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "input" "kvm" "adbusers" ];
    shell = pkgs.fish;
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";

  # System-wide settings
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.antigravity-nix.overlays.default
  ];

  programs.nix-ld.enable = true;
  zramSwap.enable = true;

  # Desktop Environment
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    withUWSM = true;
  };
  programs.dconf.enable = true;
  programs.fish.enable = true;
  qt.enable = true;
  qt.platformTheme = "qt5ct";

  # Services
  programs.ssh.startAgent = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  # Docker configuration
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "userland-proxy" = true;
      "iptables" = true;
    };
  };

  # Gaming
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamescope = {
    enable = true;
    package = pkgs.gamescope;
  };

  # Printing
  services.printing.enable = true;

  # Hardware
  hardware.bluetooth.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.xpadneo.enable = true;
  hardware.opentabletdriver.enable = false;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      intel-media-driver
    ];
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Display Manager
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme-hyprland-kath";
    wayland.enable = true;
    settings = {
      General = {
        GreeterEnvironment = "QT_SCALE_FACTOR=1.2,QT_SCREEN_SCALE_FACTORS=1.2,QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough";
      };
    };
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      kdePackages.qtbase
    ];
  };

  # XDG Portal
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  services.gvfs.enable = true;

  # SwayOSD and game controller udev rules
  services.udev.packages = with pkgs; [
    game-devices-udev-rules
    steam-devices-udev-rules
    swayosd
  ];

  # System packages (only system-level stuff)
  environment.systemPackages =
    (with pkgs-unstable; [
      amnezia-vpn
      amneziawg-tools
      codex
      gemini-cli
      throne
      yandex-music
    ])
    ++ [ (pkgs.callPackage ./ktalk.nix { }) ]
    ++ (with pkgs; [
      inputs.matugen.packages.${config.nixpkgs.hostPlatform.system}.default
      alsa-plugins
      android-tools
      aseprite
      bluetui
      font-awesome
      killall
      libnotify
      libqalculate
      mission-center
      gnome-themes-extra
      sddm-astronaut
      sddmAstronautHyprlandKathTheme
      google-antigravity-cli
      age
      bat
      bluez
      btop
      bubblewrap
      cloc
      cmake
      curl
      discord
      docker
      docker-compose
      dragon-drop
      duf
      ffmpeg
      freerdp
      fzf
      gcc
      gdb
      gimp3
      gnumake
      htop
      jq
      kdePackages.qt6ct
      krita
      lazydocker
      lazygit
      libsForQt5.qt5ct
      mangohud
      evtest
      maven
      micro
      neo
      netbird-ui
      ninja
      nixfmt
      ntfs3g
      p7zip
      pinta
      playerctl
      postman
      powertop
      protonplus
      python3
      python3Packages.pip
      python3Packages.tkinter
      python3Packages.virtualenv
      qgis
      rar
      ruff
      sddm-astronaut
      sddmAstronautHyprlandKathTheme
      scanmem
      scrcpy
      stdenv
      steam
      tenacity
      tex-fmt
      texliveFull
      transmission_4-gtk
      tree
      tmux
      unzip
      unrar
      vim
      vscode
      wget
      xclip
      xsel
      yt-dlp
      zip
    ]);

  # Fonts
  fonts.packages =
    (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts))
    ++ [
      pkgs.adwaita-fonts
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-color-emoji
    ];

  # Udev Settings
  services.udev.extraRules = ''
    # Steam Input / controller remapping needs access to uinput.
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput", TAG+="uaccess"

    # Trigger auto power-profile switch service on AC plug/unplug events
    # SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", TAG+="systemd", ENV{SYSTEMD_WANTS}+="auto-power-profile-on-battery.service"

    # Teevolution Terra
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="f523", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="f522", MODE="0666", TAG+="uaccess"

    # Wooting One Legacy
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE="0666", TAG+="uaccess"

    # Wooting One update mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2402", MODE="0666", TAG+="uaccess"

    # Wooting Two Legacy
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE="0666", TAG+="uaccess"

    # Wooting Two update mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2403", MODE="0666", TAG+="uaccess"

    # Generic Wooting devices
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", MODE="0666", TAG+="uaccess"
  '';

  # Nix
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
