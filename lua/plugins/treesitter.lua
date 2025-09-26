return {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
        vim.list_extend(opts.ensure_installed, {
            "bash",
            "html",
            "javascript",
            "java",
            "json",
            "latex",
            "bibtex",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "query",
            "regex",
            "tsx",
            "typescript",
            "vim",
            "yaml",
        })
    end,
}
