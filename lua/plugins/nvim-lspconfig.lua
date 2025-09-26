return {
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
            servers = {
                -- Python
                pyright = {},

                -- Java (jdtls will be configured separately)
                jdtls = {},

                -- LaTeX
                texlab = {
                    settings = {
                        texlab = {
                            auxDirectory = ".",
                            bibtexFormatter = "texlab",
                            build = {
                                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                                executable = "latexmk",
                                forwardSearchAfter = false,
                                onSave = false,
                            },
                            chktex = {
                                onEdit = false,
                                onOpenAndSave = true,
                            },
                            diagnosticsDelay = 300,
                            formatterLineLength = 80,
                            forwardSearch = {
                                executable = nil,
                                args = {},
                            },
                            latexFormatter = "latexindent",
                            latexindent = {
                                modifyLineBreaks = false,
                            },
                        },
                    },
                },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "jose-elias-alvarez/typescript.nvim",
            init = function()
                require("lazyvim.util").lsp.on_attach(function(_, buffer)
                    vim.keymap.set(
                        "n",
                        "<leader>co",
                        "TypescriptOrganizeImports",
                        { buffer = buffer, desc = "Organize Imports" }
                    )
                    vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
                end)
            end,
        },
        ---@class PluginLspOpts
        opts = {
            servers = {
                tsserver = {},
            },
            setup = {
                tsserver = function(_, opts)
                    require("typescript").setup({ server = opts })
                    return true
                end,
            },
        },
    },
}
