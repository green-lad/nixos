{ stdenv, fetchurl, expat, zlib }:

stdenv.mkDerivation rec {
  pname = "overpass-api";
  version = "0.7.62.5";

  src = fetchurl {
    url = "http://dev.overpass-api.de/releases/osm-3s_v${version}.tar.gz";
    sha256 = "sha256-xVSV1w9eY6IzrEGrc3LV1OG6XdRt/aUa9IsNrTxWh3I=";
  };

  buildInputs = [ expat zlib ];

  configureFlags = [
    "--prefix=${placeholder "out"}"
    "CXXFLAGS=-O2"
  ];

  # installPhase = ''
   # runHook preInstall

   # mkdir -p $out/bin
   # cp -v bin/* $out/bin/

   # runHook postInstall
  # '';

  enableParallelBuilding = true;

}
