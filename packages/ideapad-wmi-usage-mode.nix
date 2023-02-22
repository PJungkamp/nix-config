{
  stdenv,
  lib,
  fetchFromGitHub,
  linuxPackages_latest,
  kernel ? linuxPackages_latest.kernel,
  kmod,
}:
stdenv.mkDerivation rec {
  name = "ideapad-wmi-usage-mode-${version}-${kernel.version}";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "PJungkamp";
    repo = "ideapad-wmi-usage-mode";
    rev = "v${version}";
    sha256 = "sha256-4jfF6ZQiDvk9Grid/eQJwxuCqIovM7RrRLF8zzfh5cw=";
  };

  hardeningDisable = ["pic" "format"]; # 1
  nativeBuildInputs = kernel.moduleBuildDependencies; # 2

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}" # 3
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" # 4
    "INSTALL_MOD_PATH=$(out)" # 5
  ];
}
