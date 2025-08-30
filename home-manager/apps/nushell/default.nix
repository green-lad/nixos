{ config, ... }: {
  services.lorri.enable = true;
  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
  };
  
  programs.nix-your-shell = {
    enable = true;
    enableNushellIntegration = true;
  };

  # config info: config nu --doc | nu-highlight | less -R
  programs.nushell = let
    # the preview is complicated because:
    # - preview value has to be a string -> --preview=""
    # - {} gets replaced by fzf with sh escapes (' -> '\'')
    # - but we are in nushell: wrap it in raw string with unlikely (4 consecutive # needed) match
    # - and then replace '\'' with '
    # - for nix escape double quotes and backslash
    # in short: build command inside nix string variable to replace sh escapes with nushell raw string
    # echo "##'" -> 'echo "##'\''"      ->     r####'echo "##'\''"'#### -> r####'echo "##'"'#### -> echo "##'" (ingoring nix context here)
    #    fzf sh replacement   review context for nushell            str replace        raw string evaluation
    change_escape_command = cmd:
      "r####${cmd}#### | str replace -a r#''\\\\'''# r#'''#";
    fzf_search_history = str: [{
      send = "ExecuteHostCommand";
      cmd = let
        preview = "${change_escape_command "{}"} | nu-highlight";
        bind = "ctrl-y:execute-silent(${
            change_escape_command "{}"
          } | wl-copy)+abort";
      in ''
        let choice = (
          history
            | get command
            | reverse
            | uniq
            | str join (char -i 0)
            | fzf
              --scheme history
              --read0
              --layout reverse
              --height 40%
              --preview="${preview}"
              --preview-window='wrap'
              --bind="${bind}"
            | decode utf-8
            | str trim
        )
        if $choice != "" { commandline edit --${str} $choice }
      '';
    }];
    fzf_command_picker = [{
      send = "ExecuteHostCommand";
      cmd = let preview = "${change_escape_command "{3}"}";
      in ''
        let choice = (
          let c = char --unicode 7F;
          open ~/.nu_help.json
          | to csv -n -s $c
          | str join (char -i 0)
          | fzf
            --scheme history
            --tiebreak=begin
            --layout reverse
            --read0
            --delimiter $c
            --with-nth '{1} -- {2}'
            --accept-nth '{1}'
            --preview="${preview}"
            --preview-window='wrap'
            --no-multi-line
            --height 40%
        )
        if $choice != "" { commandline edit --insert $choice }
      '';
    }];
    fzf_niri_action_help = [{
      send = "ExecuteHostCommand";
      cmd = ''
        let choice = (
          niri msg action
            e>| lines
            | skip 5
            | drop 3
            | to text
            | parse -r '\s*(?P<action>.*)\n\s*(?P<description>.*)\n'
            | to csv -n -s '#'
            | str join (char -i 0)
            | fzf
                --read0
                --layout reverse
                --delimiter '#'
                --with-nth '{1} -- {2}'
                --accept-nth '{1}'
                --height 40%
        )
        if $choice != "" { commandline edit --insert $choice }
      '';
    }];
  in {
    # see: https://github.com/nix-community/home-manager/issues/4313
    shellAliases = config.home.shellAliases;
    environmentVariables = config.home.sessionVariables;
    enable = true;
    settings = {
      history = {
        sync_on_enter = false;
      };
      show_banner = false;
      edit_mode = "vi";

      cursor_shape = {
        vi_insert = "line";
        vi_normal = "block";
      };

      keybindings = [
        {
          name = "copy_working_directory";
          modifier = "control";
          keycode = "char_d";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = {
            send = "executehostcommand";
            cmd = ''$env.PWD | wl-copy'';
          };
        }
        {
          name = "copy_commandline";
          modifier = "control";
          keycode = "char_e";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = {
            send = "executehostcommand";
            cmd = ''commandline | wl-copy'';
          };
        }
        {
          name = "reload_config";
          modifier = "none";
          keycode = "f5";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = {
            send = "executehostcommand";
            cmd = ''$"source '($nu.env-path)'; source '($nu.config-path)'"'';
          };
        }
        {
          name = "unfreeze";
          modifier = "control";
          keycode = "char_z";
          event = {
            send = "executehostcommand";
            cmd = "job unfreeze";
          };
          mode = [ "emacs" "vi_normal" "vi_insert" ];
        }
        {
          name = "fuzzy_history_replace";
          modifier = "control";
          keycode = "char_k";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = fzf_search_history "replace";
        }
        {
          name = "fuzzy_history_add";
          modifier = "control";
          keycode = "char_j";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = fzf_search_history "insert";
        }
        {
          name = "fuzzy_history";
          modifier = "control";
          keycode = "char_h";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = fzf_command_picker;
        }
        {
          name = "fuzzy_niri_action_find";
          modifier = "control";
          keycode = "char_g";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = fzf_niri_action_help;
        }
      ];
    };

    extraConfig = let preview = "${change_escape_command "'{1}\\n---\\n{2}'"}";
    in ''
      use std/dirs
      if ("~/.nu_help.json" | path type) != "file" {
        (
          help commands
          | select name description
          | insert help {|r| try {help $"($r.name)"} catch {""}}
          | save "~/.nu_help.json"
        )
      }

      def "str escape" [to_escape: list<string> = [
          '\',
          '.',
          '+',
          '*',
          '?',
          '(',
          ')',
          '|',
          '[',
          ']',
          '{',
          '}',
          '^',
          '$',
          '#',
          '&',
          '-',
          '~',
          ]]: [string -> string, list<string> -> list<string>] {
          each { split chars | each {let c = $in; if ($to_escape | any {|el| $el == $c}) {$'\($c)'} else {$c}} | str join }
      }

      def "to nix" [indent_level = 2]: any -> string  {
        mut i = ""
        for _ in 1..$indent_level {$i = $i + " "}
        let indent = $i

        let identifier = ["assert","else","if","in","inherit","let","or","rec","then","with", ]
        let input = $in

        return (match ($input | describe | str replace --regex '<.*' "") {
          "string" => { $'"($input)"' }
          "int" | "float" | "bool" => { $"($input)" }
          "record" => {
            let entry = $input
              | each { transpose key value }
              | update key {
                  if not ($in in $identifier) and $in =~ "^[A-Za-z_][A-Za-z0-9_'-]*$" {
                    $in
                  } else {
                    $'"($in)"'
                  }
                }
              | update value { $in | to nix }
              | each { $"($in.key) = ($in.value);" }
              | to text
              | lines
              | each { $"($indent)($in)" }
              | to text
            $"{\n($entry)}"
          }
          "table" | "list" => {
            let entry = $input
              | each { to nix }
              | lines
              | each { $"($indent)($in)" }
              | to text
            $"[\n($entry)]"
          }
          _ => { $'"($input)"' }
        })
      }

      def test_to_nix [--fail_fast] {
        # use std/assert; assert (('{"a":1,"b":{"c":2,"d":3}}' | from json | to nix) == "a = 1;\nb = {\n  c = 2;\n  d = 3;\n};")
        let test_sets = [
          {
            name: "test_bool",
            input: false,
            expected: "false"
          }
          {
            name: "test_int",
            input: 1,
            expected: "1"
          }
          {
            name: "test_string_escape",
            input: 'a/b',
            expected: '"a/b"'
          }
          {
            name: "test_nested_record",
            input: {a:1,b:{c:2,d:3}},
            expected: "{
  a = 1;
  b = {
    c = 2;
    d = 3;
  };
}"
          }
          {
            name: "test_nested_list_string",
            input: [a,[b,[c]]],
            expected: '[
  "a"
  [
    "b"
    [
      "c"
    ]
  ]
]'
          }
          {
            name: "test_nested_list_number",
            input: [1,[2,[3]]],
            expected: '[
  1
  [
    2
    [
      3
    ]
  ]
]'
          }
          {
            name: "test_nested_mixed",
            input: {a:1,b:[2,{c:3}]},
            expected: "{
  a = 1;
  b = [
    2
    {
      c = 3;
    }
  ];
}"
          }
        ]

        mut result = []
        for $test in $test_sets {
          let actual = $test | get input | to nix
          let is_equal = $actual == $test.expected;
          $result = $result | append ($test | insert actual $actual | insert is_equal $is_equal)
          if not $is_equal and $fail_fast {
            break
          }
        }
        return {num_passed: ($result | where is_equal | length), num_failed: ($result | where not is_equal | length), detail: $result}
      }

      def rd [name: string, n_remote = 100: int] {
        mut local = [];
        if (which "cargo" | length) > 0 {
          let metadata = ( 
            cargo metadata --format-version 1
            | from json
          )
          let doc_path = $"($metadata | get target_directory)/doc"
          $local = (
            $metadata
            | get packages
            | select name description
            | where {|r| $r.name =~ $"($name)" or not ($r.description | is-empty) and $r.description =~ $"($name)"}
            | insert documentation {|r| $"file://($doc_path)/($r.name | str replace -a '-' '_')/index.html"}
            | insert local "true"
          )
        }

        let remote =  (
          http get $"https://crates.io/api/v1/crates?q='($name)'&per_page=($n_remote)"
          | get crates
          | select name description
          | insert documentation {|r| $"https://docs.rs/($r.name)"}
          | insert local "false"
        )

        let choice = (
          $local
          | append $remote
          | to csv -n -s '#'
          | str join (char -i 0)
          | str replace -a '"' ""
          | fzf
            -m
            --scheme history
            --layout reverse
            --read0
            --delimiter '#'
            --with-nth '{1} -{4}- {2}'
            --accept-nth '{3}'
            --preview="${preview}"
            --preview-window='wrap'
            --no-multi-line
            --height 40%
          | lines
          | str join " "
        );
        if $choice != "" { sh -c $"librewolf ($choice) &"}
      }
    '';
  };
}
