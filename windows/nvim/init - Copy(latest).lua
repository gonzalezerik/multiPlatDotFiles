
-- init.lua — Neovim 0.11+ (Windows-friendly), Rose Pine, C# + JS/TS
-- Dataverse helpers: dynamic PAC wizard, PRT task, floating terminal, and C# snippets.
-- After pasting: RESTART Neovim, run :Lazy sync, then restart again.

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
-- Plugins (minimal, Windows-safe) + Dataverse helpers
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
  { "Hoffs/omnisharp-extended-lsp.nvim" }, -- optional: better goto-def for C#

  -- Formatting
  { "stevearc/conform.nvim" },

  -- Autocomplete (blink.cmp)
  { "saghen/blink.cmp", version = "1.*", opts_extend = { "sources.default" } },

  -- ===== Dataverse workflow helpers =====
  -- Floating terminal for dotnet/pac
  { "akinsho/toggleterm.nvim", version = "*", config = true },
  -- Tasks (build, open PRT)
  { "stevearc/overseer.nvim", opts = {} },

  -- Snippets engine + community snippets
  { "L3MON4D3/LuaSnip", version = "v2.*" },
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
  -- OmniSharp extended handler if available
  local ok_ext, omnisharp_ext = pcall(require, "omnisharp_extended")
  if ok_ext then
    map("gd", omnisharp_ext.handler, "Go to definition (C#)")
  else
    map("gd", vim.lsp.buf.definition, "Go to definition")
  end
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
-- Dataverse workflow: toggleterm + overseer tasks + keys
-----------------------------------------------------------
local ok_toggle, toggleterm = pcall(require, "toggleterm")
if ok_toggle then toggleterm.setup({ direction = "float" }) end
vim.keymap.set("n", "<leader>tt", ":ToggleTerm<CR>", { desc = "Toggle terminal (float)" })

local ok_overseer, overseer = pcall(require, "overseer")
if ok_overseer then
  -- keep build + PRT tasks
  overseer.register_template({
    name = "dotnet build (Debug)",
    builder = function()
      return {
        cmd = { "dotnet" },
        args = { "build", "-c", "Debug" },
        cwd = vim.fn.getcwd(),
        components = { "default" },
      }
    end,
  })
  overseer.register_template({
    name = "open Plugin Registration Tool (PRT)",
    builder = function()
      return {
        cmd = { "pac" },
        args = { "tool", "prt" },
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
-- Dataverse: helpers
-----------------------------------------------------------
local uv = vim.loop
local function path_join(a, b) return (a .. "/" .. b):gsub("//+", "/") end
local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = "Dataverse" }) end
local function write_file(abs_path, content)
  local lines = {}
  for s in content:gmatch("([^\n]*)\n?") do table.insert(lines, s) end
  return vim.fn.writefile(lines, abs_path) == 0
end

-- (kept for fallback use)
local function pluginbase_template(namespace_name, class_name, entity_name)
  entity_name = entity_name or "account"
  return ([[
using Microsoft.Xrm.Sdk;
using System;

namespace %s
{
    public class %s : PluginBase
    {
        public %s(string unsecureConfiguration, string secureConfiguration)
            : base(typeof(%s))
        { }

        protected override void ExecuteDataversePlugin(ILocalPluginContext ctx)
        {
            if (ctx == null) throw new ArgumentNullException(nameof(ctx));

            var context = ctx.PluginExecutionContext;
            var service = ctx.PluginUserService;
            var trace   = ctx.TracingService;

            // Only on Create of %s
            if (!string.Equals(context.MessageName, "Create", StringComparison.OrdinalIgnoreCase) ||
                !string.Equals(context.PrimaryEntityName, "%s", StringComparison.OrdinalIgnoreCase))
                return;

            if (context.Depth > 1) return;

            var due = DateTime.UtcNow.AddDays(7);

            var task = new Entity("task");
            task["subject"]        = "Send e-mail to the new customer.";
            task["description"]    = "Follow up with the customer. Check if there are any new issues that need resolution.";
            task["scheduledstart"] = due;
            task["scheduledend"]   = due;
            task["category"]       = context.PrimaryEntityName;

            if (context.PrimaryEntityId != Guid.Empty)
            {
                task["regardingobjectid"] = new EntityReference("%s", context.PrimaryEntityId);
            }

            trace.Trace("FollowupPlugin: Creating the task activity.");
            service.Create(task);
        }
    }
}
]]):format(namespace_name, class_name, class_name, class_name, entity_name, entity_name, entity_name)
end

-- run a shell command synchronously in cwd (Windows-friendly)
local function run_in(dir, cmd, args)
  local cwd = uv.cwd()
  vim.fn.chdir(dir)
  local out = vim.fn.system({ cmd, unpack(args or {}) })
  local code = vim.v.shell_error
  vim.fn.chdir(cwd)
  return code, out
end

-----------------------------------------------------------
-- Dataverse: dynamic “new plugin” wizard (SIGNED) that edits Plugin1.cs
-----------------------------------------------------------
local function dataverse_new_plugin()
  vim.ui.input({ prompt = "Project / Folder name: " }, function(project)
    if not project or project == "" then return end

    vim.ui.input({ prompt = "C# class name (e.g. FollowupPlugin): " }, function(classname)
      if not classname or classname == "" then return end

      local namespace = project
      local root = vim.fn.getcwd()
      local proj_dir = path_join(root, project)

      if vim.fn.isdirectory(proj_dir) == 0 then
        vim.fn.mkdir(proj_dir, "p")
      end

      notify("Scaffolding signed project with PAC…")
      -- ✅ signed by default (no --skip-signing)
      local code, out = run_in(proj_dir, "pac", { "plugin", "init" })
      if code ~= 0 then
        notify("PAC init failed:\n" .. out, vim.log.levels.ERROR)
        return
      end

      -- Ensure Dataverse SDK (harmless if already present)
      run_in(proj_dir, "dotnet", { "add", "package", "Microsoft.CrmSdk.CoreAssemblies" })

      local default_file = path_join(proj_dir, "Plugin1.cs")
      local target_file  = path_join(proj_dir, classname .. ".cs")

      if vim.fn.filereadable(default_file) == 1 then
        -- read Plugin1.cs and mutate its internals only
        local lines = vim.fn.readfile(default_file)
        local new_lines = {}
        for _, line in ipairs(lines) do
          -- replace class name & references
          line = line:gsub("Plugin1", classname)
          -- replace namespace to project name
          line = line:gsub("namespace%s+[%w_%.]+", "namespace " .. namespace)
          table.insert(new_lines, line)
        end
        -- write to <Class>.cs, then remove the original Plugin1.cs
        vim.fn.writefile(new_lines, target_file)
        os.remove(default_file)
        notify("Updated and moved Plugin1.cs → " .. classname .. ".cs")
      else
        -- fallback: create a fresh file from the template if Plugin1.cs wasn't generated
        write_file(target_file, pluginbase_template(namespace, classname, "account"))
        notify("Plugin1.cs missing; wrote a fresh class file instead.")
      end

      -- open your class file
      vim.cmd("edit " .. vim.fn.fnameescape(target_file))
    end)
  end)
end

-- Map <leader>pi to the dynamic wizard
vim.keymap.set("n", "<leader>pi", dataverse_new_plugin, { desc = "Dataverse: New plugin (dynamic, signed)" })

-- Auto-sync on save & on rename (namespace/class/constructor)
local function sync_cs_namespace_and_class()
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" or not file:match("%.cs$") then return end

  local filename = vim.fn.fnamemodify(file, ":t")     -- Foo.cs
  local class    = filename:gsub("%.cs$", "")         -- Foo
  local proj     = vim.fn.fnamemodify(file, ":p:h:t") -- folder name as namespace

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local changed = false

  for i, ln in ipairs(lines) do
    -- namespace Foo.Bar → namespace <proj>
    if ln:match("^%s*namespace%s+") then
      local new = "namespace " .. proj
      if ln ~= new then lines[i] = new; changed = true end
    end
    -- public class OldName : PluginBase → class <class>
    if ln:match("^%s*public%s+class%s+") then
      local new = ln:gsub("^%s*public%s+class%s+[%w_]+", "public class " .. class)
      if new ~= ln then lines[i] = new; changed = true end
    end
    -- constructor: public OldName( … ) : base(typeof(OldName))
    if ln:match("^%s*public%s+[%w_]+%s*%(") and ln:match(":%s*base%(%s*typeof%(%s*[%w_]+%s*%)%s*%)") then
      local new = ln
        :gsub("^%s*public%s+[%w_]+%s*%(", "        public " .. class .. "(")
        :gsub("typeof%(%s*[%w_]+%s*%)", "typeof(" .. class .. ")")
      if new ~= ln then lines[i] = new; changed = true end
    end
  end

  if changed then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    notify("Synchronized namespace/class to file & folder.")
  end
end

vim.api.nvim_create_autocmd({ "BufWritePre", "BufFilePost" }, {
  pattern = { "*.cs" },
  callback = sync_cs_namespace_and_class,
})

-----------------------------------------------------------
-- C# Dataverse snippets (LuaSnip) - inline loader
-----------------------------------------------------------
local ls_ok, ls = pcall(require, "luasnip")
if ls_ok then
  local s = ls.snippet
  local t = ls.text_node
  -- PluginBase pattern (PAC template)
  ls.add_snippets("cs", {
    s("dvplugin_base", {
      t({
        "using Microsoft.Xrm.Sdk;",
        "using System;",
        "",
        "namespace BasicPlugin",
        "{",
        "    public class Plugin1 : PluginBase",
        "    {",
        "        public Plugin1(string unsecureConfiguration, string secureConfiguration)",
        "            : base(typeof(Plugin1))",
        "        { }",
        "",
        "        protected override void ExecuteDataversePlugin(ILocalPluginContext ctx)",
        "        {",
        "            if (ctx == null) throw new ArgumentNullException(nameof(ctx));",
        "            var context = ctx.PluginExecutionContext;",
        "            var service = ctx.PluginUserService;",
        "            var trace = ctx.TracingService;",
        "",
        "            // Only on Create of account",
        "            if (!string.Equals(context.MessageName, \"Create\", StringComparison.OrdinalIgnoreCase) ||",
        "                !string.Equals(context.PrimaryEntityName, \"account\", StringComparison.OrdinalIgnoreCase))",
        "                return;",
        "",
        "            if (context.Depth > 1) return;",
        "",
        "            var due = DateTime.UtcNow.AddDays(7);",
        "            var task = new Entity(\"task\");",
        "            task[\"subject\"] = \"Send e-mail to the new customer.\";",
        "            task[\"description\"] = \"Follow up with the customer. Check for any new issues.\";",
        "            task[\"scheduledstart\"] = due;",
        "            task[\"scheduledend\"] = due;",
        "            task[\"category\"] = context.PrimaryEntityName;",
        "            if (context.PrimaryEntityId != Guid.Empty)",
        "                task[\"regardingobjectid\"] = new EntityReference(\"account\", context.PrimaryEntityId);",
        "            trace.Trace(\"FollowupPlugin: Creating the task activity.\");",
        "            service.Create(task);",
        "        }",
        "    }",
        "}",
      }),
    }),
  })
  -- Raw IPlugin pattern (MS doc style)
  ls.add_snippets("cs", {
    s("dvplugin_ip", {
      t({
        "using System;",
        "using System.ServiceModel;",
        "using Microsoft.Xrm.Sdk;",
        "",
        "namespace BasicPlugin",
        "{",
        "    public class FollowupPlugin : IPlugin",
        "    {",
        "        public void Execute(IServiceProvider serviceProvider)",
        "        {",
        "            var trace = (ITracingService)serviceProvider.GetService(typeof(ITracingService));",
        "            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));",
        "            var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));",
        "            var service = factory.CreateOrganizationService(context.UserId);",
        "",
        "            if (!\"Create\".Equals(context.MessageName, StringComparison.OrdinalIgnoreCase) ||",
        "                !\"account\".Equals(context.PrimaryEntityName, StringComparison.OrdinalIgnoreCase)) return;",
        "",
        "            try {",
        "                var due = DateTime.UtcNow.AddDays(7);",
        "                var task = new Entity(\"task\");",
        "                task[\"subject\"] = \"Send e-mail to the new customer.\";",
        "                task[\"description\"] = \"Follow up with the customer.\";",
        "                task[\"scheduledstart\"] = due;",
        "                task[\"scheduledend\"] = due;",
        "                task[\"category\"] = context.PrimaryEntityName;",
        "                if (context.PrimaryEntityId != Guid.Empty)",
        "                    task[\"regardingobjectid\"] = new EntityReference(\"account\", context.PrimaryEntityId);",
        "                trace.Trace(\"FollowupPlugin: Creating the task activity.\");",
        "                service.Create(task);",
        "            }",
        "            catch (FaultException<OrganizationServiceFault> ex) {",
        "                throw new InvalidPluginExecutionException(\"Error in FollowupPlugin.\", ex);",
        "            }",
        "        }",
        "    }",
        "}",
      }),
    }),
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

