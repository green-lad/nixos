- enable flakes
```
echo "experimental-features = nix-command flake" >> /etc/nix/nix.conf
```

- get info about package
```
nix-repl
:l <nixpkgs>
:e pkgs.<package stuff>
```

- build env with package (here python3 with numpy)
```
:l <nixpkgs>
:b python3.withPackages (p: [p.numpy])
```

- get info about flake
```
nix-repl
x = builtins.getFlake "github:..."
:e x.<flake stuff>
```

- rebuild system (use "--flake path:." if files got moved)
```
sudo nixos-rebuild switch --flake .
```

- rebuild home-manager (use "--flake path:." if files got moved)
```
home-manager switch --flake .
```

- generate age key for sops (use ssh-add <private key> if the key was not generate on the machine)
```
ssh-keygen -t ed25519 -C "example@example.com" -f ~/.ssh/id_ed25519
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
age-keygen -y ~/.config/sops/age/keys.txt
```

- after key changes
```
sops updatekeys secrets.yaml
```

- evaluate nix expression, pretty print it and copy it to clipboard
```
nix-instantiate --eval <file/expression> | nixfmt | xsel -b
```

- inspect system configuration
```
nix repl
:lf <path to flake of system configuration>
nixosConfigurations.<hostname>.<...>
```

- test overlay in repl (here with an rust overlay as example)
```
nix repl
rust_overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz")
pkgs = import <nixpkgs> { overlays = [ rust_overlay ]; }
```

- move workspace to monitor
```
i3-msg '[workspace="1"]' move workspace to output dp-3
```

- mirror the screen
```
xrandr --fb 1920x1200 --output LVDS-1 --scale 1.4x1.5625 --output DP-3 --same-as LVDS-1 --scale 1
xrandr --fb 1366x768 --output LVDS-1 --scale 1 --output DP-3 --same-as LVDS-1 --scale 0.711458x0.64
```

- un-mirror the screen
```
xrandr --output LVDS-1 --scale 1x1 --output DP-3 --right-of LVDS-1 --scale 1x1
```

- firefox / librewolf increase scaling
```
about:config
layout.css.devPixelsPerPx
```

- develop on package in nixpkgs
```
nix develop nixpkgs#<pkgs_name>
```

- use python3 package that is not part of nixpkgs in flake
in let declaration:
```
modm-python-package = pkgs.python3Packages.buildPythonPackage rec {
  pname = "modm";
  version = "0.1.2";
  src = pkgs.python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "4c3edbf7fa945d3fc10c0191d1000ee5b491f3d0e43f363af3b9de12e38a5d12";
  };
  propagatedBuildInputs = [
    lbuild-python-package
    pkgs.python3Packages.lxml
    pkgs.python3Packages.pyelftools
    pkgs.python3Packages.pip
  ];
};
```
in buildInputs:
```
(python3.withPackages (python-pkgs: [
  python-pkgs.<other_package_inside_nixpkgs>
  modm-python-package
  <other_packages>
]))
```

