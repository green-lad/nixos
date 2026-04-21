{
  stdenv,
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  git,
  libfaketime,
  openssl,
  protobufc,
  which,
}:

let
  version = "0.6.7";

  src = fetchFromGitHub {
    owner = "toniebox-reverse-engineering";
    repo = "teddycloud";
    rev = "tc_v${version}";
    hash = "sha256-D3UtHf2pdHT3oIiEXsXHCJZOOgBmzcockPhiONq4pZA=";
    fetchSubmodules = true;
  };

in
stdenv.mkDerivation {
  pname = "teddycloud";
  inherit version src;

  dontConfigure = true;

  nativeBuildInputs = [
    git
    libfaketime
    openssl
    protobufc
    which
  ];

  makeFlags = [ "build" ];

  # Fix failure on build warnings
  NO_WARN_FAIL = 1;

  # Fix broken version detection
  CFLAGS = "-DBUILD_VERSION=\\\"v${version}\\\"";

  installPhase = ''
    mkdir -p $out/data/www
    cp -r bin $out
    cp -r contrib/data/www $out/data/www
  '';
}
