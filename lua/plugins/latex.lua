return {

    {
        "lervag/vimtex",
        lazy = false,
        init = function()
            vim.g.vimtex_view_method = "zathura" -- Change to your PDF viewer
            vim.g.vimtex_compiler_method = "latexmk"
            vim.g.vimtex_compiler_latexmk = {
                options = {
                    "-pdf",
                    "-shell-escape",
                    "-verbose",
                    "-file-line-error",
                    "-synctex=1",
                    "-interaction=nonstopmode",
                },
            }
            vim.g.vimtex_quickfix_mode = 0
            vim.g.vimtex_mappings_enabled = 1
            vim.g.vimtex_indent_enabled = 1
            vim.g.vimtex_syntax_enabled = 1
            vim.g.vimtex_complete_enabled = 1
            vim.g.vimtex_complete_close_braces = 1
        end,
    },

    -- LaTeX snippets
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "iurimateus/luasnip-latex-snippets.nvim",
        },
        config = function()
            require("luasnip").setup({
                enable_autosnippets = true,
                store_selection_keys = "<Tab>",
            })
            require("luasnip-latex-snippets").setup()
        end,
    },
}
