{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.helix = {
    extraPackages = with pkgs; [
      codebook
      helix-gpt
      jq
      lazygit
      nil
      nixfmt-rfc-style
      # sadly nufmt is unusable in its current state
      # nufmt
      (python3.withPackages (
        p:
        (with p; [
          python-lsp-server
        ])
      ))
      rust-analyzer
      rustfmt
      # snippet and used? word completion
      simple-completion-language-server
      texlab
      typescript-language-server
    ];
    enable = true;
    package = inputs.helix.packages.${pkgs.system}.helix;
    languages = {
      language-server = {
        uwu-colors = {
          command = "${inputs.uwu-colors.packages.${pkgs.system}.default}/bin/uwu_colors";
        };
        scls = {
          command = "simple-completion-language-server";
          config = {
            max_completion_items = 100; # set max completion results len for each group: words, snippets, unicode-input
            feature_words = true; # enable completion by word
            feature_snippets = true; # enable snippets
            snippets_first = true; # completions will return before snippets by default
            snippets_inline_by_word_tail = false; # suggest snippets by WORD tail, for example text `xsq|` become `x^2|` when snippet `sq` has body `^2`
            feature_unicode_input = false; # enable "unicode input"
            feature_paths = false; # enable path completion
            feature_citations = false; # enable citation completion (only on `citation` feature enabled)
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
        gpt = {
          command = "helix-gpt";
          args = [
            "--handler"
            "ollama"
            "--ollamaModel"
            "codellama"
            "--fetchTimeout"
            "300000"
            "--actionTimeout"
            "300000"
            "--completionTimeout"
            "300000"
            "--ollamaTimeout"
            "300000"
            "--triggerCharacters"
            ""
          ];
        };
        codebook = {
          command = "codebook-lsp";
          args = [ "serve" ];
        };
      };
      language = [
        {
          name = "csv";
          language-servers = [ "scls" ];
        }
        {
          name = "json";
          formatter.command = "${pkgs.jq}/bin/jq";
          language-servers = [ "scls" ];
        }
        {
          name = "latex";
          language-servers = [
            "texlab"
            "codebook"
            "scls"
          ];
        }
        {
          name = "markdown";
          language-servers = [
            "codebook"
            "scls"
          ];
        }
        {
          name = "nix";
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
          language-servers = [ "scls" "uwu-colors" ];
        }
        {
          name = "nu";
          # sadly nufmt is unusable in its current state
          # formatter = {
          #   command = "${pkgs.nufmt}/bin/nufmt";
          #   args = ["--stdin"];
          # };
          language-servers = [ "scls" ];
        }
        {
          name = "python";
          language-servers = [
            "pylsp"
            "gpt"
            "scls"
          ];
        }
        {
          name = "rust";
          formatter = {
            command = "rustfmt";
          };
          language-servers = [
            "rust-analyzer"
            "codebook"
            "gpt"
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
            "codebook"
            "scls"
          ];
        }
      ];

    };
    settings = {
      # theme = "iceberg-dark";

      editor = {
        mouse = false;
        continue-comments = false;
        auto-pairs = false;
        scrolloff = 0;
        line-number = "relative";
        bufferline = "always";
        end-of-line-diagnostics = "hint";
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
          auto-signature-help = false;
        };

        whitespace = {
          render = "all";
        };

        indent-guides = {
          render = false;
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
            space = "last_picker";
            C-q = ":buffer-close!";
            q = ":buffer-close";
            Q = ":buffer-close-others";
            t = {
              i = ":toggle-option lsp.display-inlay-hints";
              w = ":toggle-option soft-wrap.enable";
              x = ":toggle whitespace.render all none";
              n = ":toggle-option indent-guides.render";
              p = ":toggle-option lsp.display-progress-messages";
            };
            l = {
              r = ":lsp-restart";
              s = ":lsp-stop";
              w = ":lsp-workspace-command";
            };
            u = ":sh rm %{buffer_name}";
            i = ":open ${config.xdg.configHome}";
            I = ":config-open";
            L = ":config-reload";
            e = [
              ":sh rm -f /tmp/unique-file-u41ae14"
              ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file-u41ae14"
              '':insert-output echo "x1b[?1049h" > /dev/tty''
              ":open %sh{cat /tmp/unique-file-u41ae14}"
              ":redraw"
            ];
            E = [
              ":sh rm -f /tmp/unique-file-u41ae15"
              ":insert-output yazi --chooser-file=/tmp/unique-file-u41ae15"
              '':insert-output echo "x1b[?1049h" > /dev/tty''
              ":cd %sh{cat /tmp/unique-file-u41ae15}"
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
