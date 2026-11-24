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
    hash = "sha256-PdYmzac1i9xASa3fJlxadlgOFczjj4EPKFdHp8U45xc=";
  };

  cargoHash = "sha256-UjPk9szOnEU/KdNpL60SzVdREAoRn/KbAyh8R0Q0lzk=";

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-fPwCBFmNYfCKjKn264HuURRtLMKeSF4Pv36t/JEmfDA=";
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

