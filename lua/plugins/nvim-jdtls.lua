return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = {
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
    },
    config = function()
        local jdtls = require("jdtls")
        local jdtls_setup = require("jdtls.setup")

        local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
        local root_dir = jdtls_setup.find_root(root_markers)

        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name

        local config = {
            cmd = {
                "java",
                "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                "-Dosgi.bundles.defaultStartLevel=4",
                "-Declipse.product=org.eclipse.jdt.ls.core.product",
                "-Dlog.protocol=true",
                "-Dlog.level=ALL",
                "-Xms1g",
                "--add-modules=ALL-SYSTEM",
                "--add-opens",
                "java.base/java.util=ALL-UNNAMED",
                "--add-opens",
                "java.base/java.lang=ALL-UNNAMED",
                "-jar",
                vim.fn.glob(
                    vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"
                ),
                "-configuration",
                vim.fn.stdpath("data") .. "/mason/packages/jdtls/config_linux",
                "-data",
                workspace_dir,
            },

            root_dir = root_dir,

            settings = {
                java = {
                    eclipse = { downloadSources = true },
                    configuration = { updateBuildConfiguration = "interactive" },
                    maven = { downloadSources = true },
                    implementationsCodeLens = { enabled = true },
                    referencesCodeLens = { enabled = true },
                    format = { enabled = true },
                    saveActions = { organizeImports = true },
                },
                signatureHelp = { enabled = true },
                completion = {
                    favoriteStaticMembers = {
                        "org.hamcrest.MatcherAssert.assertThat",
                        "org.hamcrest.Matchers.*",
                        "org.hamcrest.CoreMatchers.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "java.util.Objects.requireNonNull",
                        "java.util.Objects.requireNonNullElse",
                        "org.mockito.Mockito.*",
                    },
                },
            },

            init_options = {
                bundles = {},
            },
        }

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
                jdtls.start_or_attach(config)
            end,
        })
    end,
}
