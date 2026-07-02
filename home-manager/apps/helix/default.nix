{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.helix = {
    extraPackages = with pkgs; [
      beancount-language-server
      dot-language-server
      gopls
      jq
      lazygit
      nil
      nixfmt
      prettier
      (python3.withPackages (
        p:
        (with p; [
          python-lsp-server
        ])
      ))
      simple-completion-language-server
      taplo
      tex-fmt
      texlab
      typescript-language-server
    ];
    enable = true;
    package = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix;
    languages = {
      language-server = {
        beancount-language-server = {
          command = "beancount-language-server";
          args = [ "--stdio" ];
          auto-format = true;
          config = {
            journal_file = "/var/lib/fava/ledger.bean";
          };
        };
        gopls = {
          command = "gopls";
          config = {
            gofumpt = true;
          };
        };
        taplo = {
          command = "taplo";
          args = [
            "lsp"
            "stdio"
          ];
        };
        uwu-colors = {
          command = "${inputs.uwu-colors.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/uwu_colors";
        };
        dot-language-server = {
          command = "${pkgs.dot-language-server}/bin/dot-language-server";
          args = [ "--stdio" ];
        };
        scls = {
          command = "simple-completion-language-server";
          config = {
            max_completion_items = 100;
            feature_words = false;
            feature_snippets = true;
            snippets_first = true;
            snippets_inline_by_word_tail = false;
            feature_unicode_input = false;
            feature_paths = false;
            feature_citations = false;
          };
          environment = {
            RUST_LOG = "info,simple-completion-language-server=info";
            LOG_FILE = "/tmp/completion.log";
          };
        };
        rust-analyzer = {
          config = {
            checkOnSave = {
              enable = true;
            };
            diagnostics = {
              enable = true;
            };
          };
        };
      };
      language = [
        {
          name = "beancount";
          auto-format = true;
          language-servers = [ { name = "beancount-language-server"; } ];
        }
        {
          name = "csv";
          language-servers = [ "scls" ];
        }
        {
          name = "dot";
          formatter = {
            # TODO: install the plugin for prettier by rappin prettier: https://github.com/UniqueNetwork/unique-chain/blob/bb80d781de1ea27a2ac29c02997ec3852425fd96/nix/prettier.nix#L4
            command = "npx";
            args = [
              "prettier"
              "--parser"
              "dot-parser"
            ];
          };
          language-servers = [ "dot-language-server" ];
        }
        {
          name = "json";
          formatter.command = "${pkgs.jq}/bin/jq";
          language-servers = [ "scls" ];
        }
        {
          name = "toml";
          formatter = {
            command = "taplo";
            args = [
              "format"
              "-"
            ];
          };
          language-servers = [ "taplo" ];
        }
        {
          name = "latex";
          language-servers = [
            "texlab"
            "scls"
          ];
          formatter = {
            command = "tex-fmt";
            args = [ "--stdin" ];
          };
        }
        {
          name = "markdown";
          language-servers = [
            "scls"
          ];
        }
        {
          name = "css";
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "css"
            ];
          };
          language-servers = [ "uwu-colors" ];
        }
        {
          name = "nix";
          formatter = {
            command = "${pkgs.nixfmt}/bin/nixfmt";
            args = [ "-" ];
          };
          language-servers = [
            "scls"
            "uwu-colors"
          ];
        }
        {
          name = "nu";
          formatter = {
            command = "topiary";
            args = [
              "format"
              "--language"
              "nu"
            ];
          };
          language-servers = [ "scls" ];
        }
        {
          name = "python";
          language-servers = [
            "pylsp"
            # "gpt"
            "scls"
          ];
          # this is only tmp for DiemBFT-Twins
          file-types = [
            "py"
            "da"
          ];
        }
        {
          name = "rust";
          formatter = {
            command = "rustfmt";
            args = [
              "--edition"
              "2024"
            ];
          };
          language-servers = [
            "rust-analyzer"
            # "gpt"
            "scls"
          ];
        }
        {
          name = "text";

          # not sure why those are needed according to helix
          file-types = [
            "text"
            "txt"
          ];
          scope = "source.text";

          indent = {
            tab-width = 4;
            unit = "    ";
          };
          language-servers = [
            "scls"
          ];
        }
      ];

    };
    settings = {
      editor = {
        mouse = false;
        continue-comments = false;
        auto-pairs = false;
        scrolloff = 0;
        line-number = "relative";
        bufferline = "always";
        end-of-line-diagnostics = "disable";
        inline-diagnostics = {
          cursor-line = "disable";
        };
        auto-completion = false;
        path-completion = true;
        soft-wrap = {
          enable = true;
          max-wrap = 0;
        };
        shell = [
          "nu"
          "--config"
          "${config.xdg.configHome}/nushell/config.nu"
          "--stdin"
          "-c"
        ];

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        file-picker = {
          hidden = false;
        };

        lsp = {
          snippets = false;
          auto-signature-help = false;
        };

        whitespace = {
          render = "none";
        };

        indent-guides = {
          render = true;
          character = "|";
          skip-levels = 0;
        };

        statusline = {
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "total-line-numbers"
            "primary-selection-length"
            "file-encoding"
          ];
        };
      };

      keys = {
        normal = {
          "*" = [
            "search_selection"
            "search_next"
          ];
          "A-*" = [
            "search_selection_detect_word_boundaries"
            "search_next"
          ];
          C-space = "completion";
          C-s = "signature_help";
          "A-/" = "search_selection";
          "C-?" = ''@"+p<A-/><A-d> /<ret>'';
          "C-/" = "@<A-/> /<ret>";
          C-g = [
            ":write-all"
            ":new"
            ":insert-output lazygit"
            ":buffer-close!"
            ":redraw"
            ":reload-all"
          ];
          C-e = [
            ":write-all"
            ":insert-output scooter"
            ":redraw"
            ":reload-all"
          ];
          H = [
            "jump_backward"
            "align_view_center"
          ];
          L = [
            "jump_forward"
            "align_view_center"
          ];
          X = "extend_line_above";
          W = "@glGs";
          C-h = "jump_view_left";
          C-l = "jump_view_right";
          C-k = "jump_view_up";
          C-j = "jump_view_down";
          G = {
            s = "extend_to_first_nonwhitespace";
            h = "extend_to_line_start";
            l = "extend_to_line_end";
          };
          F5 = ":config-reload";
          space = {
            B = ":sh cargo build --bin (echo '%{buffer_name}' | parse -r '(.*/)*(?<bin>.*?)/src/.*' | get 0 | get bin)";
            space = "last_picker";
            C-q = ":buffer-close!";
            q = ":buffer-close";
            Q = ":buffer-close-others";
            t = {
              f = ":toggle-option auto-format";
              i = ":toggle-option lsp.display-inlay-hints";
              w = ":toggle-option soft-wrap.enable";
              x = ":toggle whitespace.render all none";
              n = ":toggle-option indent-guides.render";
              p = ":toggle-option lsp.display-progress-messages";
              h = '':toggle-option inline-diagnostics.cursor-line "disable" "hint"'';
            };
            l = {
              r = ":lsp-restart";
              s = ":lsp-stop";
              w = ":lsp-workspace-command";
            };
            m = ":format";
            u = ":sh rm %{buffer_name}";
            i = ":open ${config.xdg.configHome}";
            I = ":config-open";
            L = ":config-reload";
            R = ":reload";
            e = [
              ":sh rm -f /tmp/unique-file-u41ae14"
              ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file-u41ae14"
              ":open %sh{cat /tmp/unique-file-u41ae14}"
              ":redraw"
            ];
            E = [
              ":sh rm -f /tmp/unique-file-u41ae15"
              ":insert-output yazi --chooser-file=/tmp/unique-file-u41ae15"
              ":cd %sh{cat /tmp/unique-file-u41ae15}"
            ];
            z = [
              '':open "~/.config/helix/snippets/%{language}.json"''
            ];
            "+" = {
              n = [
                "goto_line_end_newline"
                ":append-output 'wl-paste | from json | to nix'"
              ];
            };
            "|" = {
              c = ":pipe 'nu -c $in'";
              s = ":pipe 'lines | sort | to text --no-newline'";
              u = ":pipe 'lines | uniq | to text --no-newline'";
            };
          };
        };
        insert = {
          C-p = "signature_help";
          C-space = "completion";
        };
        select = {
          X = [
            "extend_line_up"
            "extend_to_line_bounds"
          ];
        };
      };
    };
  };
}
