{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "edu-sync-cli";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "mkroening";
    repo = "edu-sync";
    rev = "v${version}";
    hash = "sha256-7M5J+U2IEMsBaRL5Mk0USudG6zP7lXDE4ANe0XS4IxY=";
  };

  cargoHash = "sha256-m1Q3hwutI6KSA8YXSffMnatQQCityF2U/tq289ZVVcM=";
}
