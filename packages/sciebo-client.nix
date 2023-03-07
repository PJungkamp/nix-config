{
  lib,
  libsecret,
  systemd,
  libxkbcommon,
  libjpeg,
  stdenv,
  dbus,
  mtdev,
  libdrm,
  xorg,
  sqlite,
  makeWrapper,
  harfbuzz,
  wayland,
  icu67,
  pcre2,
  fontconfig,
  freetype,
  glib,
  zstd,
  openssl_1_1,
  libxcb,
  dpkg,
  fetchurl,
  autoPatchelfHook,
}: let
  repo = "https://www.sciebo.de/install/linux";
  distro = "Debian_11";
  mkRepoDependency = name: {
    pname,
    version,
    arch,
    srcHash,
    extraNativeBuildInputs ? [],
  }:
    stdenv.mkDerivation {
      inherit pname version;

      src = fetchurl {
        url = "${repo}/${distro}/${pname}_${version}_${arch}.deb";
        hash = srcHash;
      };

      nativeBuildInputs =
        [
          dpkg
          autoPatchelfHook
          stdenv.cc.cc.lib
        ]
        ++ extraNativeBuildInputs;

      unpackPhase = "dpkg-deb -x $src .";

      installPhase = ''
        if test -n "$(echo opt/ownCloud/*/share/*)" ; then
          mkdir -p $out/share
          cp -r opt/ownCloud/*/share/* $out/share
        fi

        if test -n "$(echo opt/ownCloud/*/lib/x86_64-linux-gnu/*)" ; then
          mkdir -p $out/lib
          cp -r opt/ownCloud/*/lib/x86_64-linux-gnu/* $out/lib
        fi

        if test -n "$(echo usr/*)" ; then
          mkdir -p $out
          cp -r usr/* $out
        fi
      '';
    };
  repoDependencies = builtins.mapAttrs mkRepoDependency {
    sciebo-client-overlay-icons = {
      pname = "sciebo-client-overlays-icons";
      version = "2.11.1~webfinger+oc-8491";
      arch = "all";
      srcHash = "sha256-M6yG32NQhB59XpiF94sL3ua3WXv9BD36MR4pzv8SigM=";
    };
    qtwayland5 = {
      pname = "ocqt51210-qtwayland5";
      version = "5.12.10-1";
      arch = "amd64";
      srcHash = "sha256-F/oofk909USDVMiIt5PTVriQVWawb1sOXr1X+EShC8I=";
      extraNativeBuildInputs = [
        repoDependencies.libqt5core5a
        repoDependencies.libqt5gui5
        wayland
      ];
    };
    qttranslations5 = {
      pname = "ocqt51210-qttranslations5";
      version = "5.12.10-1";
      arch = "amd64";
      srcHash = "sha256-i3BMY4eXaFn61AJUjLFegdxu8tp+c0c/aI6W7cuDQ54=";
    };
    qtsvg5 = {
      pname = "ocqt51210-qtsvg5";
      version = "5.12.10-1";
      arch = "amd64";
      srcHash = "sha256-R2QypyXzOvE2t/r4xTC9CRnRqNLpXiM0y4JAS8PSTvo=";
      extraNativeBuildInputs = [
        repoDependencies.libqt5core5a
        repoDependencies.libqt5widgets5
        repoDependencies.libqt5gui5
        zstd
      ];
    };
    libqt5xml5 = {
      pname = "ocqt51210-libqt5xml5";
      version = "5.12.10-2+25.2";
      arch = "amd64";
      srcHash = "sha256-6GGcYFYlXkrzJGnY6W5bpYYTsgMD2XsyI+AcAZYIolo=";
      extraNativeBuildInputs = [
        repoDependencies.libqt5core5a
      ];
    };
    libqt5widgets5 = {
      pname = "ocqt51210-libqt5widgets5";
      version = "5.12.10-2+25.2";
      arch = "amd64";
      srcHash = "sha256-IQsX05xeIIgJkWaAKkTz/BkWb6Y8Ja54zrGcKth1Bdk=";
      extraNativeBuildInputs = [
        repoDependencies.libqt5core5a
        repoDependencies.libqt5gui5
      ];
    };
    libqt5sql5 = {
      pname = "ocqt51210-libqt5sql5";
      version = "5.12.10-2+25.2";
      arch = "amd64";
      srcHash = "sha256-HjFN3QGcy6dCbAiMptild/fwQEaiU28Fhb4JIEPiv5k=";
      extraNativeBuildInputs = [
        repoDependencies.libqt5core5a
      ];
    };
    libqt5sql5-sqlite = {
      pname = "ocqt51210-libqt5sql5-sqlite";
      version = "5.12.10-2+25.2";
      arch = "amd64";
      srcHash = "sha256-WjccmIDhku3gFhJ+IR97gnYGWo+fUHwPtVMZe9pYuMk=";
      extraNativeBuildInputs = [
        repoDependencies.libqt5core5a
        repoDependencies.libqt5sql5
        sqlite
      ];
    };
    libqt5network5 = {
      pname = "ocqt51210-libqt5network5";
      version = "5.12.10-2+25.2";
      arch = "amd64";
      srcHash = "sha256-lLk/43MegdBPoBvufCGEWrFPAER1PIzckcrpr0MNvjY=";
      extraNativeBuildInputs = [
        repoDependencies.libqt5core5a
        zstd
        openssl_1_1
      ];
    };
    libqt5keychain1 = {
      pname = "ocqt51210-libqt5keychain1";
      version = "0.12.0-1+3.15";
      arch = "amd64";
      srcHash = "sha256-sDQHWfsbu3o/JbJmsD1Lt5fBeOWt4e+OOSt7xqVeyFk=";
      extraNativeBuildInputs = [
        repoDependencies.libqt5dbus5
        repoDependencies.libqt5core5a
        glib
      ];
    };
    libqt5gui5 = {
      pname = "ocqt51210-libqt5gui5";
      version = "5.12.10-2+25.2";
      arch = "amd64";
      srcHash = "sha256-FWSW+IbVSWXXPrZ6PRQ9v/h72pUvpPQfQ5X++d6rtSk=";
      extraNativeBuildInputs = [
        systemd
        fontconfig
        freetype
        mtdev
        harfbuzz
        libdrm
        libxcb
        libxkbcommon
        libjpeg.out
        xorg.libICE
        xorg.libSM
        repoDependencies.libqt5dbus5
        repoDependencies.libqt5network5
        repoDependencies.libqt5core5a
      ];
    };
    libqt5dbus5 = {
      pname = "ocqt51210-libqt5dbus5";
      version = "5.12.10-2+25.2";
      arch = "amd64";
      srcHash = "sha256-kVwsD2cW1Q0EQnvMaNKq70z3KF2DPIJLH7L9jXPN3c4=";
      extraNativeBuildInputs = [
        dbus
        repoDependencies.libqt5core5a
      ];
    };
    libqt5core5a = {
      pname = "ocqt51210-libqt5core5a";
      version = "5.12.10-2+25.2";
      arch = "amd64";
      srcHash = "sha256-7Jktuta3PZJ3wllbWm8Z2f+5XBqIUrYcT7fXZSpx9a4=";
      extraNativeBuildInputs = [
        zstd
        icu67
        pcre2
        glib
      ];
    };
  };
in
  stdenv.mkDerivation rec {
    pname = "sciebo-client";
    version = "2.11.1~webfinger+oc-8491";

    src = fetchurl {
      url = "${repo}/${distro}/${pname}_${version}_amd64.deb";
      hash = "sha256-R/WWjuRluNjkUvqTsxN2O1pV4Sh3Zp8hlIK7WnP3h1c=";
    };

    unpackPhase = "dpkg-deb -x $src .";

    nativeBuildInputs =
      [
        dpkg
        autoPatchelfHook
        stdenv.cc.cc.lib
        sqlite
        makeWrapper
      ]
      ++ map (name: builtins.getAttr name repoDependencies) (builtins.attrNames repoDependencies);

    installPhase = ''
      mkdir -p $out
      cp -r etc $out/
      cp -r usr/share $out/
      cp -r opt/ownCloud/sciebo/lib $out/
      cp -r opt/ownCloud/sciebo/bin $out/
      wrapProgram $out/bin/sciebo \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libsecret]} \
        --set QT_PLUGIN_PATH "${repoDependencies.libqt5gui5}/lib/qt5/plugins"
    '';
  }
