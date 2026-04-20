{ pkgs, stdenv, dpkg, autoPatchelfHook, makeWrapper, ... }:

stdenv.mkDerivation rec {
  pname = "ktalk";
  version = "3.5.1";

  src = pkgs.fetchurl {
    url = "https://st.ktalk.host/ktalk-app/linux/ktalk${version}amd64.deb";
    sha256 = "sha256-x3l80Vv5gA52O/tiqxY9xxVbz7wKKxv0W3dp6dodHx8=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = with pkgs; [
    gtk3
    nss
    alsa-lib
    at-spi2-atk
    mesa
    libdrm
    libxkbcommon
    expat
    pango
    cairo
    systemd
    pipewire
    libgbm
    libpng
    zlib
    avahi
    xorg.libX11
    xorg.libXtst
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXrandr
    xorg.libXext
    xorg.libXfixes
    xorg.libXrender
    xorg.libXi
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/pixmaps

    cp -r opt $out/ 2>/dev/null || true

    if [ -d "usr/share" ]; then
      cp -r usr/share/* $out/share/ 2>/dev/null || true
    fi

    TARGET_BIN=$(find $out/opt -maxdepth 2 -name "ktalk" -type f | head -n 1)
    if [ -n "$TARGET_BIN" ]; then
      ln -s "$TARGET_BIN" $out/bin/ktalk
    fi

    DESKTOP_FILE="$out/share/applications/ktalk.desktop"
    if [ ! -f "$DESKTOP_FILE" ]; then
      DESKTOP_FILE=$(find $out/share/applications -name "*.desktop" | head -n 1)
    fi

    if [ -f "$DESKTOP_FILE" ]; then
      sed -i "s|Exec=.*|Exec=$out/bin/ktalk|g" "$DESKTOP_FILE"

      ICON_SRC=$(find $out/share/icons -name "ktalk.png" | head -n 1)
      if [ -n "$ICON_SRC" ]; then
        cp "$ICON_SRC" $out/share/pixmaps/ktalk.png
        sed -i "s|Icon=.*|Icon=$out/share/pixmaps/ktalk.png|g" "$DESKTOP_FILE"
      fi
    fi

    runHook postInstall
  '';

  postFixup = ''
    RESOURCES_DIR=$(dirname $(find $out/opt -name "icudtl.dat" | head -n 1))

    wrapProgram $out/bin/ktalk \
      --set CHROME_ICU_DIR "$RESOURCES_DIR" \
      --set NIXOS_OZONE_WL "1" \
      --set ELECTRON_OZONE_PLATFORM_HINT "auto" \
      --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath buildInputs} \
      --add-flags "--no-sandbox --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
  '';
}
