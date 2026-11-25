{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  cargo-tauri,
  nodejs,
  npmHooks,
  pkg-config,
  libX11,
  dbus,
  glib,
  gtk3,
  libsoup_3,
  webkitgtk_4_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tine";
  version = "0.6.983";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "martinkoutecky";
    repo = "tine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aUjbN4LXT4HBi7/5zLUZyQHH7OAjK6rlVEccWQAbMlk=";
  };

  cargoHash = "sha256-EtDt8LvzFweS15t8GyH3VY54cQO9VxPHC55SA+5K2Dg=";

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-zQbe/TvMnUL3xltsM1D40JO7XWgnoM+BboVbqS72djY=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook
    pkg-config
  ];

  buildInputs = [
    libX11
    dbus
    glib
    gtk3
    libsoup_3
    webkitgtk_4_1
  ];

  buildAndTestSubdir = "src-tauri";

  tauriBuildFlags = [ "--no-bundle" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/tine $out/bin/

    runHook postInstall
  '';

  meta = {
    description = "Fast, local, Logseq-compatible outliner";
    homepage = "https://github.com/martinkoutecky/tine";
    license = lib.licenses.agpl3Only;
    mainProgram = "tine";
    maintainers = with lib.maintainers; [ fcosanabria ];
    platforms = lib.platforms.linux;
  };
})

