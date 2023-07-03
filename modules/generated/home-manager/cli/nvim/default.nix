{
  lib,
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
    checkmake
    cpplint
    nil
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
      telescope-nvim
      vim-nix
      plenary-nvim

      cmp-nvim-lsp

      nvim-lspconfig

      pkgs.vimPlugins.null-ls-nvim

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
      which-key-nvim
    ];

    extraConfig = ''
      luafile ~/.config/nvim/settings.lua
    '';
  };
}
