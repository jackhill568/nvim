vim.cmd([[set mouse=a]])
vim.cmd([[set noswapfile]])
vim.cmd([[hi @lsp.type.number gui=italic]])
vim.opt.winborder = "rounded"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.showtabline = 2
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.number = true

vim.pack.add({
	{ src = "https://github.com/nvim-neotest/nvim-nio.git",},
	{src = "https://github.com/mfussenegger/nvim-dap.git",},
	{ src = "https://github.com/niuiic/dap-utils.nvim.git",},
	{ src = "https://github.com/rcarriga/nvim-dap-ui.git", },
	{ src = "https://github.com/akinsho/toggleterm.nvim.git",},
	{ src = "https://github.com/folke/which-key.nvim.git",},
	{ src = "https://github.com/aznhe21/actions-preview.nvim.git",},
  { src = "https://github.com/ellisonleao/gruvbox.nvim.git"},
	{ src = "https://github.com/chentoast/marks.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim",          version = "0.1.8" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/LinArcX/telescope-env.nvim" },
})

require "marks".setup {
	builtin_marks = { "<", ">", "^" },
}

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'lua', 'rust', 'c', },
	callback = function() vim.treesitter.start() end,
})

require "mason".setup()

local telescope = require("telescope")
local default_color = "gruvbox"
telescope.setup({
	defaults = {
		preview = { treesitter = false },
		color_devicons = true,
		sorting_strategy = "ascending",
		borderchars = {
			"", -- top
			"", -- right
			"", -- bottom
			"", -- left
			"", -- top-left
			"", -- top-right
			"", -- bottom-right
			"", -- bottom-left
		},
		path_displays = { "smart" },
		layout_config = {
			height = 100,
			width = 400,
			prompt_position = "top",
			preview_cutoff = 40,
		}
	}
})
telescope.load_extension("ui-select")

require("actions-preview").setup {
	backend = { "telescope" },
	extensions = { "env" },
	telescope = vim.tbl_extend(
		"force",
		require("telescope.themes").get_dropdown(), {}
	)
}



vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method('textDocument/completion') then
			-- Optional: trigger autocompletion on EVERY keypress. May be slow!
			local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})

vim.cmd [[set completeopt+=menuone,noselect,popup]]

vim.lsp.enable({
	"lua_ls",
	"rust_analyzer", "clangd", "ruff",
	"glsl_analyzer", "haskell-language-server", "hlint", "cpp",
	
})

require("oil").setup({
	lsp_file_methods = {
		enabled = true,
		timeout_ms = 1000,
		autosave_changes = true,
	},
	columns = {
		"permissions",
		"icon",
	},
	float = {
		max_width = 0.7,
		max_height = 0.6,
		border = "rounded",
	},
})

require("luasnip").setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

-- ~/.config/nvim/init.lua

local function pack_clean()
	local active_plugins = {}
	local unused_plugins = {}

	for _, plugin in ipairs(vim.pack.get()) do
		active_plugins[plugin.spec.name] = plugin.active
	end

	for _, plugin in ipairs(vim.pack.get()) do
		if not active_plugins[plugin.spec.name] then
			table.insert(unused_plugins, plugin.spec.name)
		end
	end

	if #unused_plugins == 0 then
		print("No unused plugins.")
		return
	end

	local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
	if choice == 1 then
		vim.pack.del(unused_plugins)
	end
end


require("toggleterm").setup({
      shade_filetypes = {},
      direction = "vertical",  -- You can change this to "horizontal" or "vertical" if you prefer.
      size = vim.o.columns * 0.4,  -- Adjust size of the terminal window
			width = 30,
      persist_size = true,
      shading_factor = 2,
      close_on_exit = false,  -- Automatically close the terminal when the process finishes
      shell = "/bin/zsh",  -- Use default shell
			start_in_insert = true,
})
local term_buf = nil
local term_win = nil

local function toggle_terminal()
  -- Check if terminal window is open
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    -- Close the terminal window and return to normal mode
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
    vim.cmd('stopinsert')
    return
  end

  -- Create terminal buffer if it doesn't exist or is invalid
  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_call(term_buf, function()
      vim.fn.termopen("/bin/zsh")
    end)
  end

  vim.cmd('botright vsplit')
  term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(term_win, term_buf)
  vim.api.nvim_win_set_width(term_win, 80)
  vim.wo[term_win].number = false
  vim.wo[term_win].relativenumber = false
  -- Enter insert mode in terminal
  vim.cmd('startinsert')
end

vim.keymap.set("n", "<leader>pc", pack_clean)
local colors = {}
local ls = require("luasnip")
local builtin = require("telescope.builtin")
local map = vim.keymap.set
local current = 1

local dap = require("dap")
local dapui = require("dapui")

-- Setup dapui with minimal config
dapui.setup()

-- Configure C debugger with codelldb (more reliable than gdb)
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = "codelldb",
    args = { "--port", "${port}" },
  }
}

dap.configurations.c = {
  {
    name = "Launch",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.getcwd() .. "/build/main"
    end,
    cwd = vim.fn.getcwd(),
    stopOnEntry = false,
    sourceMap = {
      ["/home/ja/audioProgramming"] = "${workspaceFolder}",
    },
    sourceLanguages = { "c" },
  },
}-- Auto-open/close dapui
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

map("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
map("n", "<F10>", dap.step_over, { desc = "DAP: Step over" })
map("n", "<F11>", dap.step_into, { desc = "DAP: Step into" })
map("n", "<F12>", dap.step_out, { desc = "DAP: Step out" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
map("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
map("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })-- Keymaps
local map = vim.keymap.set
vim.g.mapleader = " "

map("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
map("n", "<F10>", dap.step_over, { desc = "DAP: Step over" })
map("n", "<F11>", dap.step_into, { desc = "DAP: Step into" })
map("n", "<F12>", dap.step_out, { desc = "DAP: Step out" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
map("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
map("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })

map({ "n", "x" }, "<leader>y", '"+y')
map({ "n", "x" }, "<leader>d", '"+d')
map({ "i", "s" }, "<C-e>", function() ls.expand_or_jump(1) end, { silent = true })
map({ "i", "s" }, "<C-J>", function() ls.jump(1) end, { silent = true })
map({ "i", "s" }, "<C-K>", function() ls.jump(-1) end, { silent = true })
map({ "n", "t" }, "<Leader>t", "<Cmd>tabnew<CR>")
map({ "n", "t" }, "<Leader>x", "<Cmd>tabclose<CR>")

map({'n', 't'}, '<leader>r', toggle_terminal, { noremap = true, silent = true })
map('t', "<esc>", "<C-\\><C-n>", { noremap = true, silent = true })
local opts = { noremap = true, silent = true }
map('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
map('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
map('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
map('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)

vim.cmd([[
	nnoremap g= g+| " g=g=g= is less awkward than g+g+g+
	nnoremap gK @='ddkPJ'<cr>| " join lines but reversed. `@=` so [count] works
	xnoremap gK <esc><cmd>keeppatterns '<,'>-global/$/normal! ddpkJ<cr>
	noremap! <c-r><c-d> <c-r>=strftime('%F')<cr>
	noremap! <c-r><c-t> <c-r>=strftime('%T')<cr>
	noremap! <c-r><c-f> <c-r>=expand('%:t')<cr>
	noremap! <c-r><c-p> <c-r>=expand('%:p')<cr>
	xnoremap <expr> . "<esc><cmd>'<,'>normal! ".v:count1.'.<cr>'
]])


for i = 1, 8 do
	map({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>")
end
map({ "n", "v", "x" }, "<leader>v", "<Cmd>edit $MYVIMRC<CR>", { desc = "Edit " .. vim.fn.expand("$MYVIMRC") })
map({ "n", "v", "x" }, "<leader>z", "<Cmd>e ~/.config/zsh/.zshrc<CR>", { desc = "Edit .zshrc" })
map({ "n", "v", "x" }, "<leader>n", ":norm ", { desc = "ENTER NORM COMMAND." })
map({ "n", "v", "x" }, "<leader>o", "<Cmd>source %<CR>", { desc = "Source " .. vim.fn.expand("$MYVIMRC") })
map({ "n", "v", "x" }, "<leader>O", "<Cmd>restart<CR>", { desc = "Restart vim." })
map({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Enter substitue mode in selection" })
map({ "n", "v", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "Format current buffer" })
map({ "v", "x", "n" }, "<C-y>", '"+y', { desc = "System clipboard yank." })
map({ "n" }, "<leader>f", builtin.find_files, { desc = "Telescope live grep" })

function git_files() builtin.find_files({ no_ignore = true }) end

function grep() builtin.live_grep({ additional_args = { "-e" } }) end

map({ "n" }, "<leader>g", grep)
map({ "n" }, "<leader>sg", git_files)
map({ "n" }, "<leader>sb", builtin.buffers)
map({ "n" }, "<leader>si", builtin.grep_string)
map({ "n" }, "<leader>so", builtin.oldfiles)
map({ "n" }, "<leader>sh", builtin.help_tags)
map({ "n" }, "<leader>sm", builtin.man_pages)
map({ "n" }, "<leader>sr", builtin.lsp_references)
map({ "n" }, "<leader>sd", builtin.diagnostics)
map({ "n" }, "<leader>si", builtin.lsp_implementations)
map({ "n" }, "<leader>sT", builtin.lsp_type_definitions)
map({ "n" }, "<leader>ss", builtin.current_buffer_fuzzy_find)
map({ "n" }, "<leader>st", builtin.builtin)
map({ "n" }, "<leader>sc", builtin.git_bcommits)
map({ "n" }, "<leader>sk", builtin.keymaps)
map({ "n" }, "<leader>se", "<cmd>Telescope env<cr>")
map({ "n" }, "<leader>sa", require("actions-preview").code_actions)
map({ "n" }, "<M-n>", "<cmd>resize +2<CR>")
map({ "n" }, "<M-e>", "<cmd>resize -2<CR>")
map({ "n" }, "<M-i>", "<cmd>vertical resize +5<CR>")
map({ "n" }, "<M-m>", "<cmd>vertical resize -5<CR>")
map({ "n" }, "<leader>e", "<cmd>Oil<CR>")
map({ "n" }, "<leader>c", "1z=")
map({ "n" }, "<C-q>", ":copen<CR>", { silent = true })
map({ "n" }, "<leader>w", "<Cmd>update<CR>", { desc = "Write the current buffer." })
map({ "n" }, "<leader>q", "<Cmd>:quit<CR>", { desc = "Quit the current buffer." })
map({ "n" }, "<leader>Q", "<Cmd>:wqa<CR>", { desc = "Quit all buffers and write." })
map({ "n" }, "<C-f>", "<Cmd>Open .<CR>", { desc = "Open current directory in Finder." })
map({ "n" }, "<leader>a", ":edit #<CR>", { desc = "Open current directory in Finder." })


vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.cmd('colorscheme ' .. default_color)
-- Run gg-repo-sync automatically after saving a PHP file
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.php",
	callback = function()
		vim.fn.jobstart("gg-repo-sync", {
			on_exit = function(_, exit_code, _)
				if exit_code == 0 then
					vim.notify("gg-repo-sync successful", vim.log.levels.INFO)
				else
					vim.notify("gg-repo-sync failed", vim.log.levels.ERROR)
				end
			end,
		})
	end,
})

require('vim._extui').enable({
	enable = true, -- Whether to enable or disable the UI.
	msg = {       -- Options related to the message module.
		---@type 'cmd'|'msg' Where to place regular messages, either in the
		---cmdline or in a separate ephemeral message window.
		target = 'cmd',
		timeout = 4000, -- Time a message is visible in the message window.
	},
})
