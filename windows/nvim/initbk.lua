-- Neovim IDE setup (init.lua) — LSP compatibility (vim.lsp.config OR lspconfig)
-- Copy to ~/.config/nvim/init.lua

------------------------------
-- Basics & Leader
------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = false
vim.o.signcolumn = "yes"
vim.o.clipboard = "unnamedplus"
vim.o.updatetime = 300
vim.o.timeoutlen = 400
vim.o.mouse = "a"
vim.o.completeopt = "menu,menuone,noselect"

-- Indentation
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"python","c","cpp","java","rust","cs"},
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

------------------------------
-- Bootstrap lazy.nvim
------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git","clone","--filter=blob:none","https://github.com/folke/lazy.nvim.git", lazypath})
end
vim.opt.rtp:prepend(lazypath)

------------------------------
-- Plugins
------------------------------
require("lazy").setup({
  {"folke/tokyonight.nvim", lazy = false, priority = 1000},
  {"nvim-lualine/lualine.nvim", dependencies = {"nvim-tree/nvim-web-devicons"}},
  {"lewis6991/gitsigns.nvim"},
  {"nvim-telescope/telescope.nvim", tag = "0.1.6", dependencies = {"nvim-lua/plenary.nvim"}},
  {"nvim-neo-tree/neo-tree.nvim", branch = "v3.x", dependencies = {"nvim-lua/plenary.nvim","nvim-tree/nvim-web-devicons","MunifTanjim/nui.nvim"}},
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},

  -- LSP / Completion
  {"williamboman/mason.nvim", version = false},
  {"williamboman/mason-lspconfig.nvim", version = false},
  {"neovim/nvim-lspconfig", version = false},
  {"hrsh7th/nvim-cmp"},
  {"hrsh7th/cmp-nvim-lsp"},
  {"hrsh7th/cmp-path"},
  {"hrsh7th/cmp-buffer"},
  {"L3MON4D3/LuaSnip"},
  {"saadparwaiz1/cmp_luasnip"},
  {"onsails/lspkind.nvim"},
  {"rafamadriz/friendly-snippets"},

  -- Formatting / Linting
  {"stevearc/conform.nvim"},
  {"mfussenegger/nvim-lint"},

  -- Terminal
  {"akinsho/toggleterm.nvim", version = "*"},

  -- Theme
  { "rose-pine/neovim", name = "rose-pine" },
    {
    'gsuuon/note.nvim',
    opts = {
      -- opts.spaces are note workspace parent directories.
      -- These directories contain a `notes` directory which will be created if missing.
      -- `<space path>/notes` acts as the note root, so for space '~' the note root is `~/notes`.
      -- Defaults to { '~' }.
      spaces = {
        '~',
        -- '~/projects/foo'
      },

      -- Set keymap = false to disable keymapping
      -- keymap = { 
      --   prefix = '<leader>n'
      -- }
    },
    cmd = 'Note',
    ft = 'note',
    keys = {
      -- You can use telescope to search the current note space:
      {'<leader>tn', -- [t]elescope [n]ote
        function()
          require('telescope.builtin').live_grep({
            cwd = require('note.api').current_note_root()
          })
        end,
        mode = 'n'
      }
    }
  },

  -- Helpers
  {"folke/which-key.nvim"},
  {"numToStr/Comment.nvim"},
  { "xiyaowong/transparent.nvim", config = function()
    require("transparent").setup({
      groups = {
        "Normal","NormalNC","NormalFloat","FloatBorder","SignColumn","LineNr",
        "CursorLine","CursorLineNr","Folded","FoldColumn","EndOfBuffer",
        "StatusLine","StatusLineNC","WinSeparator",
        "Pmenu","PmenuSel","PmenuSbar","PmenuThumb",
        "TabLine","TabLineSel","TabLineFill",
        "TelescopeNormal","TelescopeBorder",
        "NvimTreeNormal","NvimTreeNormalNC","NeoTreeNormal","NeoTreeNormalNC",
      },
      extra_groups = {},
      exclude_groups = {},
    })
  end },
}, { ui = { border = "rounded" } })

require("rose-pine").setup({
  variant = "auto",
  disable_background = true,
  disable_float_background = true,
})

------------------------------
-- Colorscheme & simple UI
------------------------------
vim.opt.termguicolors = true
vim.cmd.colorscheme("rose-pine-moon")
require("gitsigns").setup()
require("which-key").setup()
require("Comment").setup()

------------------------------
-- Neo-tree / Telescope keymaps
------------------------------
local tb = require("telescope.builtin")
vim.keymap.set("n","<leader>e", ":Neotree toggle<CR>", {silent=true, desc="File tree"})
vim.keymap.set("n","<leader>ff", tb.find_files, {desc="Find files"})
vim.keymap.set("n","<leader>fg", tb.live_grep, {desc="Live grep"})

------------------------------
-- Treesitter
------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua","vim","bash","json","yaml","toml","markdown","markdown_inline",
    "html","css","javascript","typescript","java","c","cpp","rust","python","c_sharp"
  },
  highlight = { enable = true },
  indent = { enable = true },
})


require("nvim-treesitter.configs").setup({
  ensure_installed = {
    -- ...
    "javascript","typescript","tsx","c_sharp"
  },
})

------------------------------
-- ToggleTerm
------------------------------
require("toggleterm").setup({
  direction = "float",
  open_mapping = [[<C-t>]],
  start_in_insert = true,
  on_open = function(term)
    if term and term.window then
      vim.api.nvim_set_current_win(term.window)
    end
    vim.cmd("startinsert!")
  end,
})

-- When any terminal opens, make <Esc> drop to terminal-normal so :q works
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function()
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = 0, silent = true })
  end,
})

------------------------------
-- Mason / LSP / CMP (compat shim)
------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
  "lua_ls","bashls","jsonls","yamlls",
  "html","cssls","tsserver","eslint","pyright","ruff","rust_analyzer","jdtls",
  "omnisharp",
},
})
cfg("tsserver", { on_attach = on_attach_common, capabilities = caps })
-- nvim-cmp + LuaSnip
local cmp = require("cmp")
local ok_ls, luasnip = pcall(require, "luasnip")
if ok_ls then
  require("luasnip.loaders.from_vscode").lazy_load()
end
local lspkind = require("lspkind")

cmp.setup({
  snippet = {
    expand = function(args)
      if ok_ls then luasnip.lsp_expand(args.body) end
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = function(fallback)
      if cmp.visible() then cmp.select_next_item() else fallback() end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then cmp.select_prev_item() else fallback() end
    end,
  }),
  sources = cmp.config.sources({ {name = "nvim_lsp"} }, { {name = "path"}, {name = "buffer"} }),
  formatting = { format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 }) },
})

local caps = require("cmp_nvim_lsp").default_capabilities()

local function on_attach_common(client, bufnr)
  local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc }) end
  map("gd", vim.lsp.buf.definition,  "Go to definition")
  map("gr", vim.lsp.buf.references,  "References")
  map("K",  vim.lsp.buf.hover,       "Hover")
  map("<leader>rn", vim.lsp.buf.rename,       "Rename")
  map("<leader>ca", vim.lsp.buf.code_action,  "Code action")
end

-- New API: define config, then enable it
local function cfg(name, opts) vim.lsp.config(name, opts or {}) end

-- Configure servers (override defaults), then enable
cfg("lua_ls",        { on_attach = on_attach_common, capabilities = caps })
cfg("bashls",        { on_attach = on_attach_common, capabilities = caps })
cfg("jsonls",        { on_attach = on_attach_common, capabilities = caps })
cfg("yamlls",        { on_attach = on_attach_common, capabilities = caps })
cfg("html",          { on_attach = on_attach_common, capabilities = caps })
cfg("cssls",         { on_attach = on_attach_common, capabilities = caps })
cfg("ts_ls",         { on_attach = on_attach_common, capabilities = caps })
cfg("pyright",       { on_attach = on_attach_common, capabilities = caps })
cfg("clangd",        { on_attach = on_attach_common, capabilities = caps })
cfg("rust_analyzer", { on_attach = on_attach_common, capabilities = caps })
cfg("jdtls",         { on_attach = on_attach_common, capabilities = caps })

-- Ruff: let Pyright own hover
cfg("ruff", {
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false
    on_attach_common(client, bufnr)
  end,
  capabilities = caps,
})

-- C#: Omnisharp
cfg("omnisharp", {
  capabilities = caps,
  on_attach = on_attach_common,
})

-- Now enable them (filetype-aware activation)
for _, name in ipairs({
  "lua_ls","bashls","jsonls","yamlls","html","cssls",
  "ts_ls","pyright","clangd","rust_analyzer","jdtls","ruff","omnisharp",
}) do
  vim.lsp.enable(name)
end

------------------------------
-- Formatting & Linting
------------------------------
require("conform").setup({
  formatters_by_ft = {
    lua = {"stylua"},
    javascript = {"prettierd","prettier"}, typescript = {"prettierd","prettier"},
    json = {"jq"}, html = {"prettierd","prettier"}, css = {"prettierd","prettier"},
    markdown = {"prettierd","prettier"}, python = {"ruff_format","black"},
    rust = {"rustfmt"}, c = {"clang_format"}, cpp = {"clang_format"}, java = {"google_java_format"},
    cs = {"csharpier"},
  },
})
vim.keymap.set("n","<leader>fd", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format" })

require("lint").linters_by_ft = {
  javascript = {"eslint"},
  typescript = {"eslint"},
}
vim.api.nvim_create_autocmd({"BufWritePost","InsertLeave"}, { callback = function() require("lint").try_lint() end })

------------------------------
-- Build / Run helpers (ToggleTerm)
------------------------------
local Terminal = require("toggleterm.terminal").Terminal
local build_term = Terminal:new({ direction = "float", close_on_exit = false, hidden = true })
local run_term = Terminal:new({ direction = "float", close_on_exit = false, hidden = true })

local function project_root()
  local git = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if git and git ~= '' and vim.v.shell_error == 0 then return git end
  return vim.loop.cwd()
end

local function exists(path) return vim.loop.fs_stat(path) ~= nil end

local function is_windows()
  local uname = vim.loop.os_uname()
  local s = uname and uname.sysname or ""
  return s:match("Windows") ~= nil
end

local function find_csproj(root)
  return vim.fn.globpath(root, "*.csproj") ~= ""
end

local function detect_build_cmd()
  local ft = vim.bo.filetype
  local root = project_root()
  local function in_root(name) return exists(root .. '/' .. name) end

  -- Project-based first
  if ft == 'rust' and in_root('Cargo.toml') then return 'cd ' .. root .. ' && cargo build' end
  if (ft == 'javascript' or ft == 'typescript' or ft == 'javascriptreact' or ft == 'typescriptreact') and in_root('package.json') then
    return 'cd ' .. root .. ' && npm run build'
  end
  if in_root('Makefile') or in_root('makefile') then return 'cd ' .. root .. ' && make' end
  if in_root('CMakeLists.txt') then return 'cd ' .. root .. ' && cmake -S . -B build && cmake --build build' end
  if ft == 'cs' and find_csproj(root) then return 'cd ' .. root .. ' && dotnet build' end

  -- Single-file fallbacks
  if ft == 'cpp' then return 'clang++ % -std=c++20 -O2 -g -o %:p:r' end
  if ft == 'c'   then return 'clang % -O2 -g -o %:p:r' end
  if ft == 'python' then return 'python %' end
  if ft == 'rust' then return 'cd ' .. root .. ' && cargo build' end
  if ft == 'java' then return 'javac %' end
  if ft == 'cs' then return 'csc % -out:%:p:r.exe' end
  if (ft == 'javascript' or ft == 'typescript' or ft == 'javascriptreact' or ft == 'typescriptreact') then return 'node %' end
  return nil
end

local function detect_run_cmd()
  local ft = vim.bo.filetype
  local root = project_root()
  if exists(root .. '/Cargo.toml') then return 'cd ' .. root .. ' && cargo run' end
  if exists(root .. '/package.json') then return 'cd ' .. root .. ' && npm start' end
  if ft == 'java' then return 'java %:t:r' end
  if ft == 'cpp' or ft == 'c' then return '%:p:r' end
  if ft == 'python' then return 'python %' end
  if ft == 'cs' then
    if find_csproj(root) then
      return 'cd ' .. root .. ' && dotnet run'
    else
      if is_windows() then
        return '%:p:r.exe'
      else
        if vim.fn.executable('mono') == 1 then
          return 'mono %:p:r.exe'
        else
          return '%:p:r.exe'
        end
      end
    end
  end
  return nil
end

-- Robust % expander: handles %:p:r, %:t:r, %:p, %:r, %
local function expand_percent(cmd)
  local function esc(p) return (p:gsub("([^%w])", "%%%1")) end
  local map = {
    ["%:p:r"] = vim.fn.shellescape(vim.fn.expand("%:p:r")),
    ["%:t:r"] = vim.fn.shellescape(vim.fn.expand("%:t:r")),
    ["%:p"]   = vim.fn.shellescape(vim.fn.expand("%:p")),
    ["%:r"]   = vim.fn.shellescape(vim.fn.expand("%:r")),
    ["%"]     = vim.fn.shellescape(vim.fn.expand("%")),
  }
  for _, key in ipairs({ "%:p:r", "%:t:r", "%:p", "%:r", "%" }) do
    cmd = cmd:gsub(esc(key), map[key])
  end
  return cmd
end

local function term_exec(term, cmd)
  if not cmd then
    vim.notify('No build/run command detected for this file/project', vim.log.levels.WARN)
    return
  end
  cmd = expand_percent(cmd)
  term:open()
  term:send("\r")
  term:send("\x15") -- Ctrl-U: clear to beginning of line
  term:send(cmd .. "\n")
end

-- General build/run keys
vim.keymap.set("n", "<leader>bb", function() term_exec(build_term, detect_build_cmd()) end, { desc = "Build project/file" })
vim.keymap.set("n", "<leader>rr", function() term_exec(run_term, detect_run_cmd()) end,   { desc = "Run project/file" })

-- Build **and** run quick helpers
vim.keymap.set("n", "<leader>x", function()
  local ft = vim.bo.filetype
  local cmd
  if ft == "c" then
    cmd = "clang % -O2 -g -o %:p:r && %:p:r"
  elseif ft == "cpp" then
    cmd = "clang++ % -std=c++20 -O2 -g -o %:p:r && %:p:r"
  elseif ft == "cs" then
    if find_csproj(project_root()) then
      cmd = "dotnet build && dotnet run"
    else
      if is_windows() then
        cmd = "csc % -out:%:p:r.exe && %:p:r.exe"
      else
        if vim.fn.executable('mono') == 1 then
          cmd = "csc % -out:%:p:r.exe && mono %:p:r.exe"
        else
          cmd = "csc % -out:%:p:r.exe && %:p:r.exe"
        end
      end
    end
  else
    vim.notify("Not a C/C++/C# buffer", vim.log.levels.WARN)
    return
  end
  term_exec(run_term, cmd)
end, { desc = "Build & run (C/C++/C#)" })
