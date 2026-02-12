{
  lib,
  pkgs,
  self,
  ...
}:
with lib; {
  home.packages = with pkgs; [
    nixd
    nixfmt-classic # Nix
    lua-language-server
    stylua # Lua
    clang-tools
    checkmake
    cpplint
    nil
    vscode-langservers-extracted
    deadnix
    statix
  ];

  programs.zsh.shellAliases = {
    v = "nvim";
  };

  programs.nixvim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    defaultEditor = true;

    withNodeJs = true;
    withPerl = true;
    withRuby = true;

    globals = {
      mapleader = " ";
    };

    clipboard.register = "unnamedplus";

    opts = {
      number = true;
      colorcolumn = "80";
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      wrap = false;
      swapfile = false; # Undotree
      backup = false; # Undotree
      undofile = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      foldlevelstart = 99;
    };

    #============================================================
    # Keymaps
    #============================================================
    keymaps = [
      # Window navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
      }

      # gj/gk
      {
        mode = "n";
        key = "j";
        action = "gj";
      }
      {
        mode = "n";
        key = "k";
        action = "gk";
      }

      # ; -> :
      {
        mode = "n";
        key = ";";
        action = ":";
      }
    ];

    plugins = {
      lualine.enable = true;
      treesitter = {
        enable = true;

        settings = {
          highlight = {
            enable = true;
          };
          indent = {
            enable = true;
          };
        };
      };

      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          nil_ls.enable = true;
          nixd = {
            enable = true;
            settings = {
              nixpkgs = {
                expr = ''import (builtins.getFlake "${self}").inputs.nixpkgs { }'';
              };

              formatting = {
                command = ["alejadra"];
              };
              options = {
                nixos = {
                  expr = ''
                    let configs = (builtins.getFlake "${self}").nixosConfigurations;
                    in (builtins.head (builtins.attrValues configs)).options
                  '';
                };
                home_manager = {
                  expr = ''
                    let configs = (builtins.getFlake "${self}").nixosConfigurations;
                    in (builtins.head (builtins.attrValues configs)).options.home-manager.users.type.getSubOptions []
                  '';
                };
              };
            };
          };
          statix.enable = true;
          rust_analyzer.enable = true;
          lua_ls.enable = true;
          clangd.enable = true;
          jsonls.enable = true;
          ruff.enable = true;
          html.enable = true;
          yamlls.enable = true;
          ts_ls.enable = true;
        };

        keymaps = {
          silent = true;
          lspBuf = {
            gd = {
              action = "definition";
              desc = "Goto Definition";
            };
            gr = {
              action = "references";
              desc = "Goto References";
            };
            gD = {
              action = "declaration";
              desc = "Goto Declaration";
            };
            gI = {
              action = "implementation";
              desc = "Goto Implementation";
            };
            gT = {
              action = "type_definition";
              desc = "Type Definition";
            };
            K = {
              action = "hover";
              desc = "Hover";
            };
            "<leader>cw" = {
              action = "workspace_symbol";
              desc = "Workspace Symbol";
            };
            "<leader>cr" = {
              action = "rename";
              desc = "Rename";
            };
            "<leader>ca" = {
              action = "code_action";
              desc = "Code Action";
            };
            "<leader>cf" = {
              action = "format";
              desc = "Code Action";
            };
            "<leader>sh" = {
              action = "signature_help";
              desc = "Signature Help";
            };
          };
          diagnostic = {
            "<leader>cd" = {
              action = "open_float";
              desc = "Line Diagnostics";
            };
            "[d" = {
              action = "goto_next";
              desc = "Next Diagnostic";
            };
            "]d" = {
              action = "goto_prev";
              desc = "Previous Diagnostic";
            };
          };
        };
      };
      lsp-lines.enable = true;
      lsp-format.enable = true;
      lspconfig.enable = true;
      lspsaga = {
        enable = true;
        lightbulb.enable = false;
      };

      noice.enable = true;

      which-key.enable = true;

      none-ls = {
        enable = true;
        sources.diagnostics = {
          deadnix.enable = true;
          statix.enable = true;
          cppcheck.enable = true;
          ansiblelint.enable = true;
        };
      };

      nix.enable = true;

      telescope = {
        enable = true;
        keymaps = {
          "<C-p>" = {
            action = "git_files";
            options = {
              desc = "Telescope Git Files";
            };
          };
          "<leader>fg" = "live_grep";
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            {
              name = "nvim_lsp";
              keyword_length = 1;
            }
            {
              name = "path";
              keyword_length = 3;
            }
            {
              name = "buffer";
              keyword_lenght = 4;
            }
            {name = "calc";}
            {name = "emoji";}
            {name = "luasnip";}
          ];
          mapping = {
            "<Down>" = "cmp.mapping.select_next_item()";
            "<Up>" = "cmp.mapping.select_prev_item()";
            "<C-Down>" = "cmp.mapping.scroll_docs(4)";
            "<C-Up>" = "cmp.mapping.scroll_docs(-4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';

          window = {
            documentation = {
              border = [
                "╭"
                "─"
                "╮"
                "│"
                "╯"
                "─"
                "╰"
                "│"
              ];
            };
          };
        };
      };
      luasnip.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      {
        plugin = vim-monokai;
        config = ''
          syntax on
          colorscheme monokai
        '';
      }
    ];
  };
}
