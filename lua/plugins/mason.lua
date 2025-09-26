return {
    "mason-org/mason.nvim",
    opts = {
        ensure_installed = {
            -- Formatters and linters
            "stylua",
            "shellcheck",
            "shfmt",
            "flake8",

            -- Java
            "jdtls",
            "java-debug-adapter",
            "java-test",
            "google-java-format",
            "checkstyle",

            -- LaTeX
            "texlab",
            "latexmk",
            "latexindent",
            "chktex",
        },
    },
}
