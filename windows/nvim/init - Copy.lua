
-- init.lua — Neovim 0.11+ (Windows-friendly), Rose Pine, C# + JS/TS

-----------------------------------------------------------
-- Basics
-----------------------------------------------------------
vim.opt.hlsearch = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.spelllang = "en_gb"
vim.g.mapleader = ","

-- nvim-tree: disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Clipboard
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })

-- Display / UI
vim.opt.termguicolors = true
vim.o.background = "light" -- set "dark" if you prefer
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8

-- Title + undo
vim.opt.title = true
vim.opt.titlestring = "nvim"
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true

-- Indent / tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "c", "cpp", "java", "rust", "cs" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Inlay hints (0.11+)
vim.lsp.inlay_hint.enable(true)

-----------------------------------------------------------
-- lazy.nvim bootstrap
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- Plugins (minimal, Windows-safe)
-----------------------------------------------------------
local plugins = {
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  -- Theme: Rose Pine
  { "rose-pine/neovim", name = "rose-pine" },

  -- Statusline / File tree / Finder
  { "nvim-lualine/lualine.nvim" },
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-telescope/telescope.nvim" },
  -- NOTE: skipping telescope-fzf-native to avoid 'make' error on Windows

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP stack (mason + new API usage below)
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" }, -- still needed as a dependency for server defs

  -- Formatting
  { "stevearc/conform.nvim" },

  -- Autocomplete (blink.cmp)
  { "saghen/blink.cmp", version = "1.*", opts_extend = { "sources.default" } },
}

require("lazy").setup(plugins, { ui = { border = "rounded" } })

-----------------------------------------------------------
-- UI setup
-----------------------------------------------------------
require("rose-pine").setup({
  variant = "moon",
  disable_background = false,
  disable_float_background = false,
})
vim.cmd.colorscheme("rose-pine-moon")

require("lualine").setup()
require("nvim-tree").setup()
require("telescope").setup()

-----------------------------------------------------------
-- Treesitter
-----------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua", "vim", "bash", "json", "yaml", "toml", "markdown", "markdown_inline",
    "html", "css",
    "javascript", "typescript", "tsx",   -- JS/TS/React
    "c_sharp",                           -- C#
    "python", "rust", "go", "java",
  },
  auto_install = true,
  highlight = { enable = true },
})
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

-----------------------------------------------------------
-- LSP (Mason + new 0.11 API: vim.lsp.config / vim.lsp.enable)
-----------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "jsonls",
    "yamlls",
    "html",
    "cssls",
    "ts_ls",     -- << new name (was tsserver)
    "eslint",
    "omnisharp",
  },
})

-- Capabilities (prefer blink if available)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink and blink.get_lsp_capabilities then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

local function on_attach(_, bufnr)
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
  end
  map("gd", vim.lsp.buf.definition, "Go to definition")
  map("gr", vim.lsp.buf.references, "References")
  map("K",  vim.lsp.buf.hover, "Hover")
  map("<leader>rn", vim.lsp.buf.rename, "Rename")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("]d", vim.diagnostic.goto_next, "Next diagnostic")
  map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
end

-- Helper to define, then enable servers with the new API
local function cfg(name, opts) vim.lsp.config(name, opts or {}) end

cfg("lua_ls",        { on_attach = on_attach, capabilities = capabilities,
  settings = { Lua = { diagnostics = { globals = { "vim" } }, telemetry = { enable = false } } } })
cfg("jsonls",        { on_attach = on_attach, capabilities = capabilities })
cfg("yamlls",        { on_attach = on_attach, capabilities = capabilities })
cfg("html",          { on_attach = on_attach, capabilities = capabilities })
cfg("cssls",         { on_attach = on_attach, capabilities = capabilities })
cfg("ts_ls",         { on_attach = on_attach, capabilities = capabilities }) -- JS/TS
cfg("eslint",        { on_attach = on_attach, capabilities = capabilities }) -- ESLint LSP
cfg("omnisharp",     { on_attach = on_attach, capabilities = capabilities }) -- C#

for _, name in ipairs({
  "lua_ls","jsonls","yamlls","html","cssls","ts_ls","eslint","omnisharp",
}) do
  vim.lsp.enable(name)
end

-----------------------------------------------------------
-- Formatting (Conform)
-----------------------------------------------------------
require("conform").setup({
  default_format_opts = { lsp_format = "fallback" },
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    javascriptreact = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    html = { "prettierd", "prettier" },
    css = { "prettierd", "prettier" },
    yaml = { "prettierd", "prettier" },
    markdown = { "prettierd", "prettier" },
    cs = { "csharpier" },
  },
})
vim.keymap.set("n", "<leader>fo", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format (Conform → LSP)" })

-----------------------------------------------------------
-- blink.cmp (autocomplete) — defaults are good
-----------------------------------------------------------
pcall(function() require("blink.cmp").setup({}) end)

-----------------------------------------------------------
-- QoL keymaps
-----------------------------------------------------------
vim.keymap.set("n", "<space>", ":")
vim.keymap.set("n", "q", "<C-r>")
vim.keymap.set("n", "n", "v:searchforward ? 'n' : 'N'", { expr = true })
vim.keymap.set("n", "N", "v:searchforward ? 'N' : 'n'", { expr = true })
vim.keymap.set({ "n", "v" }, ";", "getcharsearch().forward ? ',' : ';'", { expr = true })
vim.keymap.set({ "n", "v" }, "'", "getcharsearch().forward ? ';' : ','", { expr = true })
vim.keymap.set("n", "<leader>n", ":set nonumber! relativenumber!<CR>")
vim.keymap.set("n", "<leader>w", ":set wrap! wrap?<CR>")
vim.keymap.set("n", "<C-j>", "<C-W><C-J>")
vim.keymap.set("n", "<C-k>", "<C-W><C-K>")
vim.keymap.set("n", "<C-l>", "<C-W><C-L>")
vim.keymap.set("n", "<C-h>", "<C-W><C-H>")

-- nvim-tree
vim.keymap.set("n", "<C-t>", ":NvimTreeFocus<CR>")
vim.keymap.set("n", "<C-f>", ":NvimTreeFindFile<CR>")
vim.keymap.set("n", "<C-c>", ":NvimTreeClose<CR>")

-- Telescope
local tele = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tele.git_files, {})
vim.keymap.set("n", "<leader>fa", tele.find_files, {})
vim.keymap.set("n", "<leader>fg", tele.live_grep, {})
vim.keymap.set("n", "<leader>fb", tele.buffers, {})
vim.keymap.set("n", "<leader>fh", tele.help_tags, {})

