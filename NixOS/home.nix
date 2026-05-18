{ config, pkgs, ... }:

let
  ideaVersion = "2025.2.6.1";
  ideaUltimatePinned = pkgs.jetbrains.idea.overrideAttrs (_old: {
    version = ideaVersion;
    src = pkgs.fetchurl {
      url = "https://download.jetbrains.com/idea/ideaIU-${ideaVersion}.tar.gz";
      hash = "sha256-TOix8nLmQn3nCYmk5BQFSGuXxO8urN3Zv70bv5EtP7I=";
    };
  });
  ideaVmOptions = pkgs.writeText "idea64.vmoptions" ''
    -javaagent:${config.home.homeDirectory}/appcache/jetbra/ja-netfilter.jar=jetbrains
    --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
    --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
  '';
  ideaUltimateWrapped = ideaUltimatePinned.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    postFixup =
      (old.postFixup or "")
      + ''
        if [ -x "$out/bin/idea-ultimate" ]; then
          wrapProgram "$out/bin/idea-ultimate" --set IDEA_VM_OPTIONS "${ideaVmOptions}"
        fi

        if [ -x "$out/bin/idea" ]; then
          wrapProgram "$out/bin/idea" --set IDEA_VM_OPTIONS "${ideaVmOptions}"
        fi
      '';
  });

  dataGripVersion = "2025.2.3";
  dataGripPinned = pkgs.jetbrains.datagrip.overrideAttrs (_old: {
    version = dataGripVersion;
    src = pkgs.fetchurl {
      url = "https://download.jetbrains.com/datagrip/datagrip-${dataGripVersion}.tar.gz";
      hash = "sha256-fKxc4fwW7j51AKZ16/I14yhdbofA1h6DcOhH86SFKKc=";
    };
  });
  dataGripVmOptions = pkgs.writeText "datagrip64.vmoptions" ''
    -javaagent:${config.home.homeDirectory}/appcache/jetbra/ja-netfilter.jar=jetbrains
    --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
    --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
  '';
  dataGripWrapped = dataGripPinned.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    postFixup =
      (old.postFixup or "")
      + ''
        if [ -x "$out/bin/datagrip" ]; then
          wrapProgram "$out/bin/datagrip" --set DATAGRIP_VM_OPTIONS "${dataGripVmOptions}"
        fi

        if [ -x "$out/bin/datagrip.sh" ]; then
          wrapProgram "$out/bin/datagrip.sh" --set DATAGRIP_VM_OPTIONS "${dataGripVmOptions}"
        fi
      '';
  });
in

{

  imports = [
  ];

  home.stateVersion = "25.11";
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  # mimeApps
  xdg.mimeApps.enable = true;
  xdg.configFile."mimeapps.list".force = true;

  xdg.mimeApps.defaultApplications = {

    # Images
    "image/jpeg" = [ "imv.desktop" ];
    "image/png"  = [ "imv.desktop" ];
    "image/gif"  = [ "firefox.desktop" ];
    "image/webp" = [ "imv.desktop" ];
    "image/heif" = [ "imv.desktop" ];

    # Text / Code
    "text/plain" = [ "code.desktop" ];
    "text/css" = [ "code.desktop" ];
    "application/x-shellscript" = [ "code.desktop" ];
    "application/x-zerosize" = [ "code.desktop" ];
    "text/html" = [ "firefox.desktop" ];

    # Browser handlers
    "x-scheme-handler/http"  = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "application/pdf" = [ "firefox.desktop" ];
    "application/x-pdf" = [ "firefox.desktop" ];
    "application/acrobat" = [ "firefox.desktop" ];
    "application/vnd.pdf" = [ "firefox.desktop" ];
    "application/vnd.adobe.pdf" = [ "firefox.desktop" ];
    "text/pdf" = [ "firefox.desktop" ];

    # ---- Microsoft Word ----
    "application/msword" =
      [ "msword.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
      [ "msword.desktop" ];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template" =
      [ "msword.desktop" ];
    "application/vnd.ms-word.document.macroEnabled.12" =
      [ "msword.desktop" ];
    "application/rtf" =
      [ "msword.desktop" ];

    # ---- Microsoft Excel ----
    "application/vnd.ms-excel" =
      [ "msexcel.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
      [ "msexcel.desktop" ];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template" =
      [ "msexcel.desktop" ];
    "application/vnd.ms-excel.sheet.macroEnabled.12" =
      [ "msexcel.desktop" ];
    "text/csv" =
      [ "msexcel.desktop" ];

    # ---- Microsoft PowerPoint ----
    "application/vnd.ms-powerpoint" =
      [ "mspowerpoint.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
      [ "mspowerpoint.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.template" =
      [ "mspowerpoint.desktop" ];
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow" =
      [ "mspowerpoint.desktop" ];
    "application/vnd.ms-powerpoint.presentation.macroEnabled.12" =
      [ "mspowerpoint.desktop" ];

    # Audio
    "audio/mpeg" = [ "org.gnome.Decibels.desktop" ];

    # File manager
    "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

    # Video
    "video/mp4" = [ "mpv.desktop" ];
    "video/x-matroska" = [ "mpv.desktop" ];
    "video/webm" = [ "mpv.desktop" ];
    "video/ogg" = [ "mpv.desktop" ];
    "video/quicktime" = [ "mpv.desktop" ];
    "video/x-flv" = [ "mpv.desktop" ];
    "video/x-msvideo" = [ "mpv.desktop" ];
    "video/x-ms-wmv" = [ "mpv.desktop" ];
    "video/mpeg" = [ "mpv.desktop" ];
  };

  xdg.desktopEntries.steam = {
    name = "Steam";
    exec = "env STEAM_FORCE_DESKTOPUI_SCALING=1.5 GDK_SCALE=2 GDK_DPI_SCALE=0.75 steam -forcedesktopscaling 1.5 %U";
    terminal = false;
    type = "Application";
    icon = "steam";
    categories = [ "Game" "Network" ];
    mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
  };

  # Firefox with pywalfox
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.pywalfox-native ];
    languagePacks= [ "ru" ];
  };

  # Chromium 
  programs.chromium.enable = true;

  # Force browser fallback to Firefox for tools that ignore mimeapps
  home.sessionVariables = {
    BROWSER = "firefox";
  };
  
  # Fish shell configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_color_autosuggestion brblack
      set -U fish_greeting ""
    '';
    functions = {
      kitty-theme = ''
          kitty @ --to unix:/tmp/kitty set-colors /home/alex/.config/kitty/themes/Matugen.conf
          for socket in /tmp/kitty-*
            test -S "$socket"; or continue
            kitty @ --to unix:$socket set-colors /home/alex/.config/kitty/themes/Matugen.conf
          end
      '';
    };
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake /home/alex/hyprland-dotfiles/NixOS#nixos";
      nrb = "sudo nixos-rebuild boot --flake /home/alex/hyprland-dotfiles/NixOS#nixos";
      nfu = "nix flake update --flake /home/alex/hyprland-dotfiles/NixOS";
      nce = "vim /home/alex/hyprland-dotfiles/NixOS/configuration.nix";
      nhe = "vim /home/alex/hyprland-dotfiles/NixOS/home.nix";
      nfe = "vim /home/alex/hyprland-dotfiles/NixOS/flake.nix";
      try = "nix-shell -p";
      ncg = "sudo nix-collect-garbage -d";
      neo = "neo --colormode=32 -C /home/alex/.config/neo/colors-matugen.neo";
      ls = "eza -la";
      dcuw = "docker compose -f /home/alex/.config/windows-docker/compose.yaml up -d";
      dcdw = "docker compose -f /home/alex/.config/windows-docker/compose.yaml down";
      dnd = "dragon-drop -x -A";
      g = "lazygit";
      d = "lazydocker";
      dwa = "yt-dlp -x --audio-format mp3 --cookies-from-browser firefox -N 50";
      dla = "yt-dlp -x --audio-format mp3 --enable-file-urls";
    };
  };
  
  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Alexander";
        email = "alexo375@yandex.ru";
      };
    };
  };

  # SwayOSD service
  services.swayosd.enable = true;

  # KDE Connect configuration
  services.kdeconnect = {
    package = 
      pkgs.kdePackages.kdeconnect-kde
    ;
    enable = true;
    indicator = true;
  };
  
  # OBS for screen recording
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
    package = pkgs.obs-studio.override {
      cudaSupport = true; 
    };
  };

  # Video Player
  programs.mpv = {
    enable = true;
  };
  
  # Kitty Terminal configuration
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    settings = {
      include = "current-theme.conf";
      font_size = 14;
      cursor_trail = 5;
      scrollback_indicator_opacity = 0;
      window_padding_width = 20;
      placement_strategy = "top-left";
      hide_window_decorations = "yes";
      resize_debounce_time = "0 0";
      confirm_os_window_close = 0;
      background_opacity = 0.8;
      background_blur = 0;
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      "map shift+cmd+plus" = "change_font_size all +2.0";
      "map shift+cmd+minus" = "change_font_size all -2.0";
      "map shift+cmd+backspace" = "change_font_size all 14";
    };
    font = {
      size = 14;
      name = "FiraCode Nerd Font";
      package = pkgs.nerd-fonts.fira-code;
    };
  };
  programs.rofi = {
    enable = true;
    plugins = [ pkgs.rofi-calc ];
    package = pkgs.rofi;
    configPath = ".config/rofi/.hm-config.rasi";
  };

  programs.home-manager.enable = true;

  home.file.".local/bin" = {
    source = ../misc/bin;
    recursive = true;
  };

  # User-specific packages
  home.packages = with pkgs; [
    adw-gtk3
    android-tools
    ani-cli
    asciiquarium-transparent
    blueman
    brightnessctl
    cava
    cbonsai
    cliphist
    dconf-editor
    decibels
    eza
    file-roller
    gimp
    git
    gnome-clocks
    grim
    gthumb
    heroic
    hypridle
    hyprlock
    hyprpicker
    hyprpolkitagent
    hyprshot
    hyprsunset
    imv
    ideaUltimateWrapped
    dataGripWrapped
    jq
    kdePackages.kamera
    libreoffice
    nautilus
    nitch
    nwg-look
    obsidian
    pamixer
    pavucontrol
    python3
    python3Packages.pip
    python3Packages.virtualenv
    pywalfox-native
    rofimoji
    slurp
    socat
    stow
    swaynotificationcenter
    swww
    telegram-desktop
    tesseract
    unimatrix
    wf-recorder
    vscode
    waybar
    wl-clip-persist
    wl-clipboard
    yazi
    zenity
  ];
}
