{ config, pkgs, inputs, pkgs-unstable, lib, ... }:

let
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
    timeout = 0;
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
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
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.resumeDevice = "/dev/disk/by-uuid/c95c8d22-0de2-4e0d-a8f4-d0951c736c83";
  boot.plymouth = {
    enable = true;
    themePackages = [ pkgs.adi1090x-plymouth-themes ];
    theme = "connect";
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

  services.resolved.enable = true;
  services.netbird.enable = true;

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
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
  };

  # Use power-profiles-daemon for explicit manual profile switching.
  # TLP conflicts with this workflow by reapplying AC/BAT policies.
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  # MateBook firmware exposes incomplete adaptive thermal zones for thermald.
  # Run thermald in non-adaptive mode to avoid service startup failure.
  systemd.services.thermald.serviceConfig.ExecStart = lib.mkForce
    "${pkgs.thermald}/sbin/thermald --no-daemon --dbus-enable";

  systemd.services.auto-power-profile-on-battery = {
    description = "Auto switch power profile to balanced on battery";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    wants = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      mains_online=0
      for ps in /sys/class/power_supply/*; do
        if [ -f "$ps/type" ] && [ -f "$ps/online" ] && [ "$(cat "$ps/type")" = "Mains" ]; then
          if [ "$(cat "$ps/online")" = "1" ]; then
            mains_online=1
            break
          fi
        fi
      done

      if [ "$mains_online" = "0" ]; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced || true
      else
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance || true
      fi
    '';
  };

  # Throne Settings
  security.wrappers.Throne = {
    source = "${pkgs-unstable.throne}/bin/Throne";
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin+ep";
  };

  # Throne TUN config talks to systemd-resolved through three privileged calls
  # (default route, DNS servers, domains). Allow them for alex without 3 prompts.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var ids = [
        "org.freedesktop.resolve1.set-default-route",
        "org.freedesktop.resolve1.set-dns-servers",
        "org.freedesktop.resolve1.set-domains"
      ];
      if (ids.indexOf(action.id) >= 0 && subject.user == "alex") {
        return polkit.Result.YES;
      }
    });
  '';

  # RPCS3 memory lock fix
  security.pam.loginLimits = [
    { domain = "@users"; type = "soft"; item = "memlock"; value = "unlimited"; }
    { domain = "@users"; type = "hard"; item = "memlock"; value = "unlimited"; }
  ];

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

  # Environment variables
  environment.localBinInPath = true;
  environment.variables = {
    QT_QPA_PLATFORM = "wayland";
    _JAVA_OPTIONS = "-Dawt.toolkit.name=WLToolkit";
    NIXOS_OZONE_WL = "1";
    ELECTRON_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    EDITOR = "micro";
    JAVA_HOME = "${pkgs.jdk21}/lib/openjdk";
  };

  # User account
  users.users.alex = {
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
  programs.nix-ld.enable = true;
  zramSwap.enable = true;

  # Desktop Environment
  programs.hyprland.enable = true;
  programs.dconf.enable = true;
  programs.fish.enable = true;

  # Services
  programs.kdeconnect.package = pkgs.kdePackages.kdeconnect-kde;
  programs.kdeconnect.enable = true;
  programs.ssh.startAgent = true;
  programs.adb.enable = true;

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
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
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

  # SwayOSD udev rules
  services.udev.packages = [ pkgs.swayosd ];

  # System packages (only system-level stuff)
  environment.systemPackages =
    (with pkgs-unstable; [
      amnezia-vpn
      amneziawg-tools
      codex
      throne
      yandex-music
    ])
    ++ [ (pkgs.callPackage ./ktalk.nix { }) ]
    ++ (with pkgs; [
      inputs.matugen.packages.${config.nixpkgs.hostPlatform.system}.default
      alsa-plugins
      aseprite
      bluetui
      flameshot
      font-awesome
      killall
      libnotify
      libqalculate
      mission-center
      nix-search-tv
      gnome-themes-extra
      sddm-astronaut
      sddmAstronautHyprlandKathTheme
      age
      bat
      bluez
      btop
      bubblewrap
      cloc
      cmake
      cpufetch
      curl
      discord
      docker
      docker-compose
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
      kdePackages.kcachegrind
      kdePackages.kstatusnotifieritem
      kdePackages.qt6ct
      lazydocker
      lazygit
      libsForQt5.qt5ct
      mangohud
      maven
      micro
      neo
      netbird-ui
      ninja
      nixfmt-rfc-style
      ntfs3g
      openai-whisper
      p7zip
      pipx
      postman
      powertop
      ppsspp-sdl-wayland
      protonplus
      python3
      python3Packages.pip
      python3Packages.tkinter
      python3Packages.virtualenv
      qgis
      rpcs3
      ruff
      ranger
      sddm-astronaut
      sddmAstronautHyprlandKathTheme
      scanmem
      scrcpy
      stdenv
      steam
      tenacity
      tex-fmt
      texliveFull
      tree
      tmux
      unzip
      unrar
      valgrind
      vim
      vscode
      wget
      winetricks
      xclip
      xsel
      yt-dlp
    ]);

  # Compatibility
  # Codex CLI expects a system bubblewrap at /usr/bin/bwrap.
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/bwrap - - - - ${pkgs.bubblewrap}/bin/bwrap"
  ];

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
    # Trigger auto power-profile switch service on AC plug/unplug events
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", TAG+="systemd", ENV{SYSTEMD_WANTS}+="auto-power-profile-on-battery.service"

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

  system.stateVersion = "25.11";
}
