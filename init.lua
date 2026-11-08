-- ~/.config/nvim/init.lua  (Neovim 0.12)
-- Languages: C, Python, Java, TypeScript/React, Bash (+ Rust, Lua, Haskell, GLSL)

------------------------------------------------------------
-- Leader MUST be set before any <leader> mapping
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

------------------------------------------------------------
-- Options
------------------------------------------------------------
local o = vim.opt
o.mouse = "a"
o.swapfile = false
o.undofile = true
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.wrap = false
o.termguicolors = true
o.showtabline = 1 -- only when 2+ tabs (valid range is 0-2; 4 was out of range)
o.cursorline = true
o.scrolloff = 8
o.sidescrolloff = 8
o.splitright = true
o.splitbelow = true
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"
o.updatetime = 250
o.timeoutlen = 400
o.confirm = true -- ask instead of failing on :q with unsaved changes
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
o.pumheight = 12

-- Indentation: 4 spaces by default, 2 for web/lua (below). Makefiles keep tabs
-- automatically via Neovim's own ftplugin.
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true
o.smartindent = true

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"lua",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"jsonc",
		"html",
		"css",
		"yaml",
		"sh",
		"bash",
	},
	callback = function()
		vim.bo.tabstop, vim.bo.shiftwidth, vim.bo.softtabstop = 2, 2, 2
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})

-- Jump back to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(a)
		local mark = vim.api.nvim_buf_get_mark(a.buf, '"')
		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(a.buf) then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

------------------------------------------------------------
-- Plugins (built-in vim.pack)
------------------------------------------------------------
local gh = function(path)
	return "https://github.com/" .. path
end

vim.pack.add({
	-- UI / quality of life
	gh("ellisonleao/gruvbox.nvim"),
	gh("nvim-tree/nvim-web-devicons"),
	gh("folke/which-key.nvim"),
	gh("echasnovski/mini.nvim"), -- pairs, surround, statusline
	gh("lewis6991/gitsigns.nvim"),
	gh("chentoast/marks.nvim"),
	gh("stevearc/oil.nvim"),
	gh("akinsho/toggleterm.nvim"),

	-- Finder
	gh("nvim-lua/plenary.nvim"),
	{ src = gh("nvim-telescope/telescope.nvim"), version = "master" },
	gh("nvim-telescope/telescope-ui-select.nvim"),
	gh("aznhe21/actions-preview.nvim"),

	-- Syntax
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	gh("windwp/nvim-ts-autotag"), -- auto-close/rename JSX/TSX/HTML tags

	-- LSP / tooling
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason.nvim"),
	gh("mfussenegger/nvim-jdtls"), -- Java (configured in ftplugin/java.lua)
	gh("stevearc/conform.nvim"),

	-- Snippets
	gh("L3MON4D3/LuaSnip"),

	-- Debugging
	gh("nvim-neotest/nvim-nio"),
	gh("mfussenegger/nvim-dap"),
	gh("rcarriga/nvim-dap-ui"),
})

------------------------------------------------------------
-- Colorscheme (re-apply tweaks whenever it changes)
------------------------------------------------------------
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "@lsp.type.number", { italic = true })
	end,
})
vim.cmd.colorscheme("gruvbox")

------------------------------------------------------------
-- Small plugins
------------------------------------------------------------
require("which-key").setup()
require("marks").setup({ builtin_marks = { "<", ">", "^" } })
require("nvim-ts-autotag").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.statusline").setup()
require("gitsigns").setup({
	on_attach = function(buf)
		local gs = require("gitsigns")
		local m = function(l, r, d)
			vim.keymap.set("n", l, r, { buffer = buf, desc = d })
		end
		m("]h", function()
			gs.nav_hunk("next")
		end, "Next hunk")
		m("[h", function()
			gs.nav_hunk("prev")
		end, "Prev hunk")
		m("<leader>hp", gs.preview_hunk, "Preview hunk")
		m("<leader>hs", gs.stage_hunk, "Stage hunk")
		m("<leader>hr", gs.reset_hunk, "Reset hunk")
		m("<leader>hb", gs.blame_line, "Blame line")
	end,
})

require("oil").setup({
	default_file_explorer = true,
	lsp_file_methods = { enabled = true, timeout_ms = 1000, autosave_changes = true },
	columns = { "permissions", "icon" },
	view_options = { show_hidden = true },
	float = { max_width = 0.7, max_height = 0.6, border = "rounded" },
})

require("toggleterm").setup({
	direction = "vertical",
	size = function()
		return math.floor(vim.o.columns * 0.4)
	end,
	open_mapping = [[<M-t>]], -- works in normal and terminal mode
	persist_size = true,
	close_on_exit = false,
	shell = vim.o.shell,
	start_in_insert = true,
	shade_terminals = false,
})

------------------------------------------------------------
-- Telescope
------------------------------------------------------------
local telescope = require("telescope")
telescope.setup({
	defaults = {
		sorting_strategy = "ascending",
		path_displays = { "smart" },
		layout_config = { prompt_position = "top", preview_cutoff = 80 },
		file_ignore_patterns = { "node_modules/", "%.git/", "target/", "build/", "__pycache__/" },
		preview = { treesitter = false },
		current_buffer_fuzzy_find = { results_ts_highlight = false },
	},
	pickers = {
		find_files = { hidden = true },
	},
})
telescope.load_extension("ui-select")

require("actions-preview").setup({
	backend = { "telescope" },
	telescope = require("telescope.themes").get_dropdown(),
})

------------------------------------------------------------
-- Treesitter (main branch API)
------------------------------------------------------------
local parsers = {
	"c",
	"cpp",
	"java",
	"python",
	"rust",
	"lua",
	"bash",
	"javascript",
	"typescript",
	"tsx",
	"json",
	"html",
	"css",
	"xml",
	"yaml",
	"toml",
	"markdown",
	"markdown_inline",
	"glsl",
	"haskell",
	"vim",
	"vimdoc",
	"query",
	"regex",
	"diff",
	"gitcommit",
}
require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
	callback = function(a)
		-- start highlighting if a parser exists for this filetype; ignore otherwise
		if pcall(vim.treesitter.start, a.buf) then
			vim.bo[a.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

------------------------------------------------------------
-- Mason: installs tools (LSP servers, formatters, debuggers)
------------------------------------------------------------
require("mason").setup()
local registry = require("mason-registry")
registry.refresh(function()
	local wanted = {
		-- LSP
		"lua-language-server",
		"pyright",
		"ruff",
		"clangd",
		"rust-analyzer",
		"typescript-language-server",
		"eslint-lsp",
		"json-lsp",
		"html-lsp",
		"css-lsp",
		"bash-language-server",
		"jdtls",
		"glsl_analyzer",
		-- formatters / linters
		"stylua",
		"prettier",
		"shfmt",
		"shellcheck",
		"clang-format",
		-- debuggers
		"codelldb",
		"debugpy",
		"js-debug-adapter",
		"java-debug-adapter",
		"java-test",
		-- treesitter
		"tree-sitter-cli",
	}
	for _, name in ipairs(wanted) do
		local ok, pkg = pcall(registry.get_package, name)
		if ok and not pkg:is_installed() then
			pkg:install()
		end
	end
end)

------------------------------------------------------------
-- LSP
------------------------------------------------------------
-- 0.11+/0.12 give you these by default, no mapping needed:
--   grn rename | gra code action | grr references | gri implementation
--   grt type definition | gO document symbols | K hover | <C-s> (insert) signature help
--   ]d / [d diagnostics | gd is NOT default (use <C-]> or the Telescope maps below)

vim.diagnostic.config({
	virtual_text = { current_line = true },
	severity_sort = true,
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("clangd", {
	cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
})

-- Ruff does lint/format/imports; Pyright does types. Stop pyright duplicating ruff.
vim.lsp.config("pyright", {
	settings = {
		pyright = { disableOrganizeImports = true },
		python = { analysis = { typeCheckingMode = "standard" } },
	},
})
vim.lsp.config("ruff", {
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
})

vim.lsp.config("rust_analyzer", {
	settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
})

-- NOTE: jdtls is deliberately NOT enabled here. nvim-jdtls starts it from
-- ftplugin/java.lua so debugging and tests work.
vim.lsp.enable({
	"lua_ls",
	"pyright",
	"ruff",
	"clangd",
	"rust_analyzer",
	"ts_ls",
	"eslint",
	"jsonls",
	"html",
	"cssls",
	"bashls",
})

-- Only enable these if you actually have the binaries (they're not on Mason for every OS)
if vim.fn.executable("haskell-language-server-wrapper") == 1 then
	vim.lsp.enable("hls")
end
if vim.fn.executable("glsl_analyzer") == 1 then
	vim.lsp.enable("glsl_analyzer")
end

-- Native LSP completion (autotrigger on letters + common punctuation, not on space)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp", {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		local buf = args.buf

		if client:supports_method("textDocument/completion") then
			local chars, seen = {}, {}
			local function add(c)
				if not seen[c] then
					seen[c] = true
					table.insert(chars, c)
				end
			end
			for i = string.byte("a"), string.byte("z") do
				add(string.char(i))
				add(string.char(i):upper())
			end
			for _, c in ipairs({ ".", ":", ">", "_", "/", "@", "$", "<", '"', "'" }) do
				add(c)
			end
			for _, c in ipairs(client.server_capabilities.completionProvider.triggerCharacters or {}) do
				add(c)
			end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
		end

		if client:supports_method("textDocument/inlayHint") then
			vim.keymap.set("n", "<leader>lh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
			end, { buffer = buf, desc = "Toggle inlay hints" })
		end
	end,
})

------------------------------------------------------------
-- Formatting (conform): LSP fallback for Java/Rust/etc.
------------------------------------------------------------
local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_organize_imports", "ruff_format" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		markdown = { "prettier" },
		yaml = { "prettier" },
	},
	format_on_save = function(buf)
		if vim.g.disable_autoformat or vim.b[buf].disable_autoformat then
			return
		end
		return { timeout_ms = 1500, lsp_format = "fallback" }
	end,
})
vim.api.nvim_create_user_command("FormatToggle", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
	print("Format on save: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
end, {})

------------------------------------------------------------
-- Snippets
------------------------------------------------------------
local ls = require("luasnip")
ls.setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/snippets/" })

------------------------------------------------------------
-- Debugging (DAP)
------------------------------------------------------------
local dap, dapui = require("dap"), require("dapui")
dapui.setup()
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

local mason_pkgs = vim.fn.stdpath("data") .. "/mason/packages"
local ask_exe = function()
	return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
end

-- C / C++ / Rust
dap.adapters.codelldb = { type = "executable", command = "codelldb" }
dap.configurations.c = {
	{ name = "Launch", type = "codelldb", request = "launch", program = ask_exe, cwd = "${workspaceFolder}" },
}
dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.c

-- Python
dap.adapters.python = {
	type = "executable",
	command = mason_pkgs .. "/debugpy/venv/bin/python",
	args = { "-m", "debugpy.adapter" },
}
dap.configurations.python = {
	{
		name = "Launch file",
		type = "python",
		request = "launch",
		program = "${file}",
		pythonPath = function()
			local venv = vim.env.VIRTUAL_ENV
			return venv and (venv .. "/bin/python") or vim.fn.exepath("python3")
		end,
	},
}

-- JS / TS / React (Node)
dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = { command = "js-debug-adapter", args = { "${port}" } },
}
for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
	dap.configurations[ft] = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
	}
end
-- Java is wired up in ftplugin/java.lua via nvim-jdtls

------------------------------------------------------------
-- Keymaps
------------------------------------------------------------
local map = vim.keymap.set
local builtin = require("telescope.builtin")

-- Clipboard
map({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "x" }, "<leader>d", '"+d', { desc = "Delete to system clipboard" })

-- Files / search
map("n", "<leader>f", builtin.find_files, { desc = "Find files" })
map("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "File explorer" })
map("n", "-", "<cmd>Oil<CR>", { desc = "Parent directory" })
map("n", "<leader>sg", function()
	builtin.find_files({ no_ignore = true, hidden = true })
end, { desc = "Find files (incl. ignored)" })
map("n", "<leader>sb", builtin.buffers, { desc = "Buffers" })
map("n", "<leader>sw", builtin.grep_string, { desc = "Grep word under cursor" })
map("n", "<leader>so", builtin.oldfiles, { desc = "Recent files" })
map("n", "<leader>sh", builtin.help_tags, { desc = "Help" })
map("n", "<leader>sm", builtin.man_pages, { desc = "Man pages" })
map("n", "<leader>sr", builtin.lsp_references, { desc = "LSP references" })
map("n", "<leader>si", builtin.lsp_implementations, { desc = "LSP implementations" })
map("n", "<leader>sT", builtin.lsp_type_definitions, { desc = "LSP type definitions" })
map("n", "<leader>sd", builtin.diagnostics, { desc = "Diagnostics" })
map("n", "<leader>ss", builtin.current_buffer_fuzzy_find, { desc = "Search in buffer" })
map("n", "<leader>sS", builtin.lsp_document_symbols, { desc = "Document symbols" })
map("n", "<leader>st", builtin.builtin, { desc = "Telescope pickers" })
map("n", "<leader>sc", builtin.git_bcommits, { desc = "Buffer git commits" })
map("n", "<leader>sk", builtin.keymaps, { desc = "Keymaps" })
map("n", "<leader>sa", require("actions-preview").code_actions, { desc = "Code actions (preview)" })
map("n", "gd", builtin.lsp_definitions, { desc = "Go to definition" })

-- Formatting
map({ "n", "v" }, "<leader>lf", function()
	conform.format({ lsp_format = "fallback" })
end, { desc = "Format" })

-- Diagnostics
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>lq", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })

-- Tabs
map("n", "<Leader>t", "<Cmd>tabnew<CR>", { desc = "New tab" })
map({ "n", "t" }, "<Leader>x", "<Cmd>tabclose<CR>", { desc = "Close tab" })
for i = 1, 8 do
	map({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>", { desc = "Tab " .. i })
end

-- Windows
map("n", "<M-n>", "<cmd>resize +2<CR>")
map("n", "<M-e>", "<cmd>resize -2<CR>")
map("n", "<M-i>", "<cmd>vertical resize +5<CR>")
map("n", "<M-m>", "<cmd>vertical resize -5<CR>")

-- Terminal
map("t", "<esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })
for _, k in ipairs({ "h", "j", "k", "l" }) do
	map("t", "<C-" .. k .. ">", "<Cmd>wincmd " .. k .. "<CR>", { silent = true })
end

-- Snippets
map({ "i", "s" }, "<C-e>", function()
	ls.expand_or_jump(1)
end, { silent = true })
map({ "i", "s" }, "<C-j>", function()
	ls.jump(1)
end, { silent = true })
map({ "i", "s" }, "<C-k>", function()
	ls.jump(-1)
end, { silent = true })

-- Completion menu: Tab / S-Tab to move, Enter keeps its normal meaning
map("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
map("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

-- Debugging
map("n", "<F5>", dap.continue, { desc = "DAP continue" })
map("n", "<F10>", dap.step_over, { desc = "DAP step over" })
map("n", "<F11>", dap.step_into, { desc = "DAP step into" })
map("n", "<F12>", dap.step_out, { desc = "DAP step out" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
map("n", "<leader>dr", dap.repl.open, { desc = "DAP REPL" })

-- Misc
map({ "n", "v", "x" }, "<leader>n", ":norm ", { desc = "Enter :norm command" })
map({ "n", "v", "x" }, "<leader>o", "<Cmd>source %<CR>", { desc = "Source current file" })
map({ "n", "v", "x" }, "<leader>O", "<Cmd>restart<CR>", { desc = "Restart Neovim" })
map({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Substitute in selection" })
map("n", "<leader>c", "1z=", { desc = "Fix spelling with first suggestion" })
map("n", "<C-q>", "<cmd>copen<CR>", { silent = true, desc = "Open quickfix" })
map("n", "<leader>w", "<Cmd>update<CR>", { desc = "Write buffer" })
map("n", "<leader>q", "<Cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>Q", "<Cmd>wqa<CR>", { desc = "Write all and quit" })
map("n", "<C-f>", function()
	vim.ui.open(".")
end, { desc = "Open cwd in file manager" }) -- cross-platform
map("n", "<leader>u", "<cmd>Undotree<CR>", { desc = "Undo tree" })

-- Centered scrolling / searching
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Built-in plugins shipped with Neovim 0.12
vim.cmd.packadd("nvim.undotree")

vim.cmd([[
	nnoremap g= g+| " g=g=g= is less awkward than g+g+g+
	nnoremap gK @='ddkPJ'<cr>| " join lines but reversed
	xnoremap gK <esc><cmd>keeppatterns '<,'>-global/$/normal! ddpkJ<cr>
	noremap! <c-r><c-d> <c-r>=strftime('%F')<cr>
	noremap! <c-r><c-t> <c-r>=strftime('%T')<cr>
	noremap! <c-r><c-f> <c-r>=expand('%:t')<cr>
	noremap! <c-r><c-p> <c-r>=expand('%:p')<cr>
	xnoremap <expr> . "<esc><cmd>'<,'>normal! ".v:count1.'.<cr>'
]])

------------------------------------------------------------
-- Plugin management
------------------------------------------------------------
local function pack_clean()
	local unused = {}
	for _, p in ipairs(vim.pack.get()) do
		if not p.active then
			table.insert(unused, p.spec.name)
		end
	end
	if #unused == 0 then
		return print("No unused plugins.")
	end
	if vim.fn.confirm("Remove unused plugins?\n" .. table.concat(unused, "\n"), "&Yes\n&No", 2) == 1 then
		vim.pack.del(unused)
	end
end
map("n", "<leader>pc", pack_clean, { desc = "Pack: clean unused" })
map("n", "<leader>pu", function()
	vim.pack.update()
end, { desc = "Pack: update plugins" })
