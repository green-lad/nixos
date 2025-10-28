{ ... }:
{ }
# TODO: not used yet, to be continued ...
# { pkgs ? import <nixpkgs> { } }:

# pkgs.stdenv.mkDerivation {
#   pname = "simple-blender-addons";
#   version = "1.0"; # You can specify the version you want

#   src = pkgs.fetchFromGitHub {
#     owner = "green-lad";
#     repo = "SimpleBlenderAddons";
#     rev = "main"; # or a specific commit hash
#     sha256 =
#       "0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; # Replace with the actual hash
#   };

#   buildInputs = [ pkgs.blender ];

#   installPhase = ''
#     mkdir -p $out/share/blender/addons
#     cp -r * $out/share/blender/addons/
#   '';

#   meta = with pkgs.lib; {
#     description = "A collection of simple Blender addons";
#     homepage = "https://github.com/green-lad/SimpleBlenderAddons";
#     license = licenses.mit; # Adjust the license as necessary
#     maintainers = with maintainers;
#       [ yourName ]; # Replace with your name or leave empty
#   };
# }
