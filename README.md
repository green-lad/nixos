# About
This is my nixos configuration.
To list a few, it uses:
- [home-manager](https://github.com/nix-community/home-manager)
- firefox-addons
- [disko](https://github.com/nix-community/disko)
- [sops-nix](https://github.com/Mic92/sops-nix)

In [commands.md](./commands.md) is a list of usefule commands.

# Installation
- enable root login via ssh (/etc/ssh/sshd_config: PermitRootLogin yes)
- start sshd
- change hostname to desired name (<host>)
- deploy system: (add "--generate-hardware-config nixos-generate-config ./host_hardware/<host>/default.nix" to generate initial hardware config)
> sudo nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake 'github:green-lad/nixos#<host>' --target-host root@<host>
- install manually:
    - setup wireless connection (start wpa_supplicant service and use wpa_cli to configure)
    - add host configuration to remote flake
    - install via disko:
    > sudo nix --experimental-features 'nix-command flakes' run github:nix-community/disko#disko-install -- --flake 'github:green-lad/nixos#<host>' --write-efi-boot-entries --disk main '<disk>'
- (sops-nix won't work, you need to create your own secrets)

# Program info
## Firefox / Librewolf
I use [shyfox](https://github.com/Naezr/ShyFox) but mashed into [userchrome.css](./home-manager/apps/firefox/userChrome.css) and [usercontent.css](./home-manager/apps/firefox/userContent.css) with slight changes.
To play around with it enable remote debugging in firefox / librewolf and open it via ctrl+alt+shift+i.

# TODO
- librewolf:
    - Get bookmarks working (waiting for: https://github.com/NixOS/nixpkgs/issues/400250 -> https://github.com/NixOS/nixpkgs/pull/398612)
    - Also configure firefox plugins like sideberry or violetmonkey to not have to configure them on first use
    - Make a search engine which can query multiple arguments (for example github search engine: searchTerm, language)

- nushell:
    - find a way to output existing operators on types (eg filesize type)
    - make scrolling easier by being able to collapse outputs of commands
    - make every command work (prefer) piped input: `ls ../**/* | get name | where {$in =~ xil_cache.h} | get 1 | path dirname | ls`
    - anonymous named pipes would be nice for something like: `diff <(foo | bar) <(baz | quux)`
    - ctrl-? to view help info about the nearest command in the pipe (ie: for cursor "_" in "ls | where name == _" it shows "help -f where")
    - visualize whitespace characters like helix does
    - there are problems with tab completion when the element contains spaces (the auto completed stays when choosing an item making the choice invalid)
    - use std/dirs in combination with pipelines (I don't know why it does not work, sth about env and pipes...): `[".." "../.."] | each {dirs add}` (better yet without the each)
    - get fzf working when in a nested shell like nix-shell (it seems to get parsed from bash)

- helix:
    - questions:
        - what do I do if pipe command hangs?
    - setup:
        - open multiple files via yazi
        - sort items in info box "auto-info" by keybinding
        - global search of selection via Ctrl+s does not work
        - don't change the view position if the search was not successful
        - setup auto complete with words from current buffers as source (vim: C-n)
        - sometimes the cursor in not clearly visible when selecting for example whitespace (color scheme problem)
        - always show current working directory
        - open url in selection in browser
        - calling edit from lazygit hangs the whole process
        - when running ":input-output rg <searchTerm>" the line number gets removed for some reason
        - when using gf also support line numbers at the end, eg "~/.zshrc:50"
        - also toggle signature info for variables (signature_help), current alternative: toggle inlay hints for everything
        - lsp formatting is inconsistent sometimes (originated from search_engines.url.template)
    - missing features
        - support folds / narrowing
        - toggle using regex match with backreference (eg: in helix tutor first task match repeating characters)
        - same motions in search and command mode (command line behaves just like another buffer with like 5 lines similar too vims command-line window, suggestions come from pseudo language server)
        - disable language server features on the fly (eg: run diagnostics only when prompted)
        - selection history tree (edited selections get removed?)

- misc:
    - use overlay instead of overwriting specialArgs.pkgs
    - add ./home-manager/scripts path (see sth like: https://ertt.ca/nix/shell-scripts/)
    - add music quickly (via url link from clipboard, fuzzle, yt-dlp) to local music
    - Reset root system (impermanence)
    - Get realtime kernel and linuxcnc working
    - Get nixos-anywhere working again (when running it, nixos-installer gets booted; disko stuff seems fine, maybe sops-nix is the problem) 
    - Get iampfilter working (https://github.com/RaitoBezarius/nixos-home/blob/a6e318e7385daf673808384729c3de111b061e49/emails/imapfilter/default.nix#L16)
    - have a something that converts json to nix (see: https://github.com/sempruijs/json2nix) that can be called via helix pipe

