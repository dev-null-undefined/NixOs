local o = vim.opt
local g = vim.g

-- Autocmds
vim.cmd [[
   augroup CursorLine
   au!
   au VimEnter * setlocal cursorline
   au WinEnter * setlocal cursorline
   au BufWinEnter * setlocal cursorline
   au WinLeave * setlocal nocursorline
   augroup END

   autocmd FileType nix setlocal shiftwidth=4
]]

-- Keybinds
local map = vim.api.nvim_set_keymap
local opts = { silent = true, noremap = true }

map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
map('n', '<C-n>', ':Telescope live_grep <CR>', opts)
map('n', '<C-f>', ':Telescope find_files <CR>', opts)
map('n', 'j', 'gj', opts)
map('n', 'k', 'gk', opts)
map('n', ';', ':', { noremap = true })

g.mapleader = ' '

-- Performance
o.lazyredraw = true;
o.shell = "zsh"
o.shadafile = "NONE"

-- Colors
o.termguicolors = true

-- Undo files
o.undofile = true

-- Indentation
o.tabstop = 4
o.expandtab = true
o.scrolloff = 5

-- Set clipboard to use system clipboard
o.clipboard = "unnamedplus"

-- Use mouse
o.mouse = "a"

-- Nicer UI settings
o.cursorline = true
o.relativenumber = true
o.number = true

-- Get rid of annoying viminfo file
o.viminfo = ""
o.viminfofile = "NONE"

-- Miscellaneous quality of life
o.ignorecase = true
o.ttimeoutlen = 5
o.hidden = true
o.shortmess = "atI"
o.wrap = false
o.backup = false
o.writebackup = false
o.errorbells = false
o.swapfile = false
o.showmode = false
o.laststatus = 3
o.pumheight = 6
o.splitright = true
o.splitbelow = true
o.completeopt = "menuone,noselect"

require('telescope').setup()

local telescope_builtin = require('telescope.builtin')

local function on_attach(client, bufnr)
end

local wk = require("which-key")

wk.register({
    f = {
        name = "file",
        f = { "<cmd>Telescope find_files<cr>", "Find File" },
        g = { "<cmd>Telescope live_grep<cr>", "Live file grep" },
        b = { "<cmd>Telescope buffers<cr>", "Chose buffer" },
        r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
    },
    c = {
        name = "code",
        f = { vim.lsp.buf.format, "Format document" },
        a = { vim.lsp.buf.code_action, "Format document" },
        e = { vim.diagnostic.open_float, "Open floating error message" },
        l = { vim.lsp.codelens.run, "Run code lens" },
    },
    g = {
        name = "Move",
        d = { telescope_builtin.lsp_definitions, "Go to definitions" },
        D = { vim.lsp.buf.declaration, "Go to declaration" },
        i = { telescope_builtin.lsp_implementations, "Go to implementation" },
        y = { telescope_builtin.lsp_type_definitions, "Go to type defintion" },
        r = { telescope_builtin.lsp_references, "Go to references" },
    }
}, { prefix = "<leader>" })

-- lsp
local lspconfig = require("lspconfig")

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities = vim.lsp.protocol.make_client_capabilities()
local servers = { "rust_analyzer", "lua_ls", "nixd", "clangd", "nil_ls" }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        -- after 150ms of no calls to lsp, send call
        -- compare with throttling that is done by default in compe
        -- flags = {
        --   debounce_text_changes = 150,
        -- }
    })
end


local null_ls = require("null-ls")

null_ls.setup({
    on_attach = on_attach,
    sources = {
        null_ls.builtins.diagnostics.deadnix,   -- nix
        null_ls.builtins.diagnostics.statix,    -- nix
        null_ls.builtins.diagnostics.checkmake, -- make
        null_ls.builtins.diagnostics.cppcheck,  -- cpp
        null_ls.builtins.diagnostics.cpplint,   -- cpp

        null_ls.builtins.formatting.alejandra, -- nix
    },
})

-- luasnip setup
local luasnip = require 'luasnip'

-- Autocomplete
-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
        ['<C-d>'] = cmp.mapping.scroll_docs(4),  -- Down
        -- C-b (back) C-f (forward) for snippet placeholder navigation.
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
    },
}
