{
  lib,
  config,
  pkgs,
  ...
}:
with lib; {
  home.file.".config/nvim/settings.lua".source = ./init.lua;

  home.packages = with pkgs; [
    nixd
    nixfmt # Nix
    sumneko-lua-language-server
    stylua # Lua
    clang-tools
  ];

  programs.zsh = {
    initExtra = ''
      export EDITOR="nvim"
    '';

    shellAliases = {
      v = "nvim";
    };
  };

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      {
        plugin = vim-monokai;
        config = "syntax on
                    colorscheme monokai";
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = "require('lualine').setup()";
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          require('telescope').setup()
        '';
      }
      vim-nix
      plenary-nvim

      cmp-nvim-lsp

      nvim-lspconfig

      # completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip
      luasnip

      {
        plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup {
              highlight = {
                  enable = true,
              },
          }
        '';
      }
    ];

    extraConfig = ''
      luafile ~/.config/nvim/settings.lua
    '';
  };
}
