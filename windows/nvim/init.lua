-- :contentReference[oaicite:0]{index=0}
-- init.lua — Neovim 0.11+ (Windows-friendly)
-- Full setup for Blink.CMP + LuaSnip + D365/Dataverse + JS PowerApps snippets

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

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.clipboard:append({ "unnamed", "unnamedplus" })
vim.opt.termguicolors = true
vim.o.background = "light"
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8

vim.opt.title = true
vim.opt.titlestring = "nvim"
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true

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

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.lsp.inlay_hint.enable(true)

-----------------------------------------------------------
-- Filetype tweaks
-----------------------------------------------------------
vim.filetype.add({
  extension = {
    resx = "xml",
    svg  = "xml",
    xslt = "xml",
    xsl  = "xml",
  },
})

-----------------------------------------------------------
-- lazy.nvim bootstrap
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- Plugins
-----------------------------------------------------------
local plugins = {
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "rose-pine/neovim", name = "rose-pine" },
  { "nvim-lualine/lualine.nvim" },
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-telescope/telescope.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { "Hoffs/omnisharp-extended-lsp.nvim" },
  { "stevearc/conform.nvim" },

  
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      "rafamadriz/friendly-snippets",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        -- Tab cycles down the list AND live-inserts the selection
        ["<Tab>"] = {
          function(cmp) return cmp.select_next({ auto_insert = true }) end,
          "fallback",
        },
        -- Shift-Tab goes back up
        ["<S-Tab>"] = {
          function(cmp) return cmp.select_prev({ auto_insert = true }) end,
          "fallback",
        },
        -- Enter confirms/expands the highlighted item
        ["<CR>"] = { "accept", "fallback" },
      },

      appearance = { nerd_font_variant = "mono" },

      completion = {
        trigger = {
          prefetch_on_insert = true,
          show_on_keyword = true,
          show_on_trigger_character = true,
        },
        menu = {
          auto_show = true,
          auto_show_delay_ms = 0,
          border = "rounded",
        },
        -- Auto insert while navigating so you see it inline as you Tab around
        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 120 },
        ghost_text = { enabled = false },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
      snippets = { preset = "luasnip" },
    },
    opts_extend = { "sources.default" },
  },

  { "akinsho/toggleterm.nvim", version = "*", config = true },
  { "stevearc/overseer.nvim", opts = {} },
  { "rafamadriz/friendly-snippets" },
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
    "html", "css", "javascript", "typescript", "tsx", "xml", "c_sharp",
    "python", "rust", "go", "java"
  },
  auto_install = true,
  highlight = { enable = true },
})
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

-----------------------------------------------------------
-- LSP setup
-----------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls", "jsonls", "yamlls", "html", "cssls",
    "ts_ls", "eslint", "omnisharp",
    "lemminx", "emmet_language_server", "stylelint_lsp"
  },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink and blink.get_lsp_capabilities then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

local function on_attach(_, bufnr)
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
  end
  local ok_ext, omnisharp_ext = pcall(require, "omnisharp_extended")
  if ok_ext then
    map("gd", omnisharp_ext.handler, "Go to definition (C#)")
  else
    map("gd", vim.lsp.buf.definition, "Go to definition")
  end
  map("gr", vim.lsp.buf.references, "References")
  map("K", vim.lsp.buf.hover, "Hover")
  map("<leader>rn", vim.lsp.buf.rename, "Rename")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("]d", vim.diagnostic.goto_next, "Next diagnostic")
  map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
end

local function cfg(name, opts) vim.lsp.config(name, opts or {}) end
cfg("lua_ls", { on_attach = on_attach, capabilities = capabilities })
cfg("ts_ls", { on_attach = on_attach, capabilities = capabilities })
cfg("eslint", { on_attach = on_attach, capabilities = capabilities })
cfg("omnisharp", { on_attach = on_attach, capabilities = capabilities })
cfg("lemminx", { on_attach = on_attach, capabilities = capabilities })
cfg("emmet_language_server", { on_attach = on_attach, capabilities = capabilities })
cfg("stylelint_lsp", { on_attach = on_attach, capabilities = capabilities })
for _, name in ipairs({
  "lua_ls", "ts_ls", "eslint", "omnisharp",
  "lemminx", "emmet_language_server", "stylelint_lsp"
}) do vim.lsp.enable(name) end

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
    xml = { "xmllint" },
    svg = { "svgo" },
  },
})
vim.keymap.set("n", "<leader>fo", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format (Conform → LSP)" })

-----------------------------------------------------------
-- LuaSnip: load custom PowerApps JS snippets
-----------------------------------------------------------
pcall(function()
  require("luasnip.loaders.from_vscode").lazy_load()
  local cfg = vim.fn.stdpath("config") .. "/lua/snippets"
  if vim.fn.isdirectory(cfg) == 1 then
    require("luasnip.loaders.from_lua").lazy_load({ paths = cfg })
  end
  require("snippets.powerapps_js")
end)

pcall(function()
  local ls = require("luasnip")
  ls.filetype_extend("typescript", { "javascript" })
  ls.filetype_extend("javascriptreact", { "javascript" })
  ls.filetype_extend("typescriptreact", { "javascript" })
end)

-- IMPORTANT: Let blink.cmp drive <Tab>/<S-Tab> for accepting/jumping.
-- We remove custom LuaSnip <Tab> mappings to avoid conflicts.
local ok_ls, ls = pcall(require, "luasnip")
if ok_ls then
  ls.config.set_config({ history = true, updateevents = "TextChanged,TextChangedI" })
end

-- Completion UX
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-----------------------------------------------------------
-- Dataverse workflow: toggleterm + overseer tasks + keys
-----------------------------------------------------------
local ok_toggle, toggleterm = pcall(require, "toggleterm")
if ok_toggle then toggleterm.setup({ direction = "float" }) end
vim.keymap.set("n", "<leader>tt", ":ToggleTerm<CR>", { desc = "Toggle terminal (float)" })

local ok_overseer, overseer = pcall(require, "overseer")
if ok_overseer then
  overseer.register_template({
    name = "dotnet build (Debug)",
    builder = function()
      return { cmd = { "dotnet" }, args = { "build", "-c", "Debug" }, cwd = vim.fn.getcwd(), components = { "default" } }
    end,
  })
  overseer.register_template({
    name = "open Plugin Registration Tool (PRT)",
    builder = function()
      return { cmd = { "pac" }, args = { "tool", "prt" }, cwd = vim.fn.getcwd(), components = { "default" } }
    end,
  })
  overseer.register_template({
    name = "minify webresources (esbuild)",
    builder = function()
      return {
        cmd = { "node" },
        args = {
          "-E",
          [[
            const {execSync} = require('child_process');
            try {
              execSync('esbuild --bundle src/new_/Scripts/*.js --minify --outdir=upload/new_/Scripts', {stdio:'inherit'});
              execSync('esbuild src/new_/Styles/*.css --minify --outdir=upload/new_/Styles', {stdio:'inherit'});
              console.log('Minify complete.');
            } catch (e) { process.exit(1); }
          ]]
        },
        cwd = vim.fn.getcwd(),
        components = { "default" },
      }
    end,
  })
  vim.keymap.set("n", "<leader>db", function() overseer.run_template({ name = "dotnet build (Debug)" }) end,
    { desc = "dotnet build Debug" })
  vim.keymap.set("n", "<leader>pp", function() overseer.run_template({ name = "open Plugin Registration Tool (PRT)" }) end,
    { desc = "Open PRT" })
end

-----------------------------------------------------------
-- Snippets (LuaSnip) — D365 Web Resources quick helpers
-----------------------------------------------------------
local ls_ok2, ls2 = pcall(require, "luasnip")
if ls_ok2 then
  local s = ls2.snippet
  local t = ls2.text_node
  local i = ls2.insert_node

  -- $webresource directive (XML attr value)
  ls2.add_snippets("xml", {
    s("webres", { t('$webresource:'), i(1, 'new_/path/file.ext') }),
  })

  -- Xrm.Navigation.openWebResource
  ls2.add_snippets("javascript", {
    s("xopen", {
      t('Xrm.Navigation.openWebResource("'), i(1, 'new_/path/page.htm'),
      t('", '), i(2, 'encodeURIComponent("first=One&second=Two")'),
      t(", "), i(3, "{ openInNewWindow: true, height: 600, width: 800 }"), t(");")
    }),
  })
  ls2.add_snippets("html", {
    s("linkcss",  { t('<link rel="stylesheet" type="text/css" href="../styles/'),  i(1, 'styles.css'),   t('" />') }),
    s("scriptjs", { t('<script type="text/javascript" src="../scripts/'),          i(1, 'myScript.js'), t('"></script>') }),
    s("imgwr",    { t('<img src="../Images/'),                                     i(1, 'image1.png'),  t('" />') }),
  })

  -- Load community snippets too
  pcall(function() require("luasnip.loaders.from_vscode").lazy_load() end)
end

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
vim.keymap.set("n", "<C-t>", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<C-f>", ":NvimTreeFindFile<CR>")

-- Telescope
local tele = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tele.git_files, {})
vim.keymap.set("n", "<leader>fa", tele.find_files, {})
vim.keymap.set("n", "<leader>fg", tele.live_grep, {})
vim.keymap.set("n", "<leader>fb", tele.buffers, {})
vim.keymap.set("n", "<leader>fh", tele.help_tags, {})

-----------------------------------------------------------
-- Cheat Sheets picker — opens PDFs from your directory
-----------------------------------------------------------
-- Your cheatsheets directory (Windows)
vim.g.cheatsheets_dir = "C:\\Users\\egonzalez\\github\\workNotes\\cheatsheets"

-- OS-aware opener
local function _open_pdf_external(path)
  if not path or path == "" then
    return vim.notify("No file selected.", vim.log.levels.WARN)
  end
  local file = vim.fn.fnameescape(path)
  local sys = vim.loop.os_uname().sysname
  if sys == "Windows_NT" then
    vim.fn.jobstart({ "cmd.exe", "/c", "start", "", file }, { detach = true })
  elseif sys == "Darwin" then
    vim.fn.jobstart({ "open", file }, { detach = true })
  else
    vim.fn.jobstart({ "xdg-open", file }, { detach = true })
  end
end

-- Scan for PDFs (uses plenary if available)
local function _scan_cheats(dir)
  local ok, scandir = pcall(require, "plenary.scandir")
  if ok then
    return scandir.scan_dir(dir, { depth = 4, add_dirs = false, search_pattern = "%.pdf$" })
  end
  local list = vim.fn.globpath(dir, "**/*.pdf", true, true)
  table.sort(list)
  return list
end

-- Picker logic (Telescope or fallback)
local function _pick_and_open()
  local dir = vim.g.cheatsheets_dir
  if dir == "" or vim.fn.isdirectory(dir) == 0 then
    return vim.notify("Cheatsheets dir not found: " .. tostring(dir), vim.log.levels.ERROR)
  end

  local files = _scan_cheats(dir)
  if not files or #files == 0 then
    return vim.notify("No PDFs found in " .. dir, vim.log.levels.WARN)
  end

  local ok_telescope = pcall(require, "telescope")
  if ok_telescope then
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
      prompt_title = "Cheat Sheets",
      finder = finders.new_table({ results = files }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(_, map)
        local open_selected = function(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          _open_pdf_external(entry[1] or entry.value)
        end
        map("i", "<CR>", open_selected)
        map("n", "<CR>", open_selected)
        return true
      end,
    }):find()
  else
    vim.ui.select(files, {
      prompt = "Open cheat sheet:",
      format_item = function(item) return vim.fn.fnamemodify(item, ":t") end,
    }, function(choice)
      if choice then _open_pdf_external(choice) end
    end)
  end
end

-- Commands + keymap
vim.api.nvim_create_user_command("Cheats", function() _pick_and_open() end,
  { desc = "Pick a cheat-sheet PDF and open externally" })

vim.api.nvim_create_user_command("SetCheatsDir", function(opts)
  local p = opts.args ~= "" and opts.args or vim.fn.input("Cheats dir: ", vim.g.cheatsheets_dir)
  if p and p ~= "" then
    vim.g.cheatsheets_dir = vim.fn.expand(p)
    vim.notify("Cheatsheets dir set to: " .. vim.g.cheatsheets_dir)
  end
end, { nargs = "?", complete = "dir", desc = "Set cheat-sheets directory" })

vim.keymap.set("n", "<leader>cs", ":Cheats<CR>", { desc = "Cheat Sheets picker" })
