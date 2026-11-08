--- ~/.config/nvim/ftplugin/java.lua
-- Starts jdtls through nvim-jdtls so debugging (java-debug-adapter) and tests (java-test) work.

local ok, jdtls = pcall(require, "jdtls")
if not ok then
	return
end

local mason = vim.fn.stdpath("data") .. "/mason"
local root = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
	or vim.fn.getcwd()
local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fs.basename(root)

-- Debug + test bundles installed by Mason
local bundles = {}
local function add(glob)
	for _, jar in ipairs(vim.split(vim.fn.glob(glob, true), "\n", { trimempty = true })) do
		if
			not jar:find("com.microsoft.java.test.runner-jar-with-dependencies", 1, true)
			and not jar:find("jacocoagent", 1, true)
		then
			table.insert(bundles, jar)
		end
	end
end
add(mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")
add(mason .. "/packages/java-test/extension/server/*.jar")

jdtls.start_or_attach({
	cmd = {
		mason .. "/bin/jdtls",
		-- use the java on PATH instead of whatever $JAVA_HOME points at
		"--java-executable=" .. vim.fn.exepath("java"),
		"-data",
		workspace,
	},
	root_dir = root,
	settings = {
		java = {
			signatureHelp = { enabled = true },
			completion = { favoriteStaticMembers = { "org.junit.jupiter.api.Assertions.*" } },
			format = { enabled = true },
		},
	},
	init_options = { bundles = bundles },
	on_exit = function(code, signal)
		vim.schedule(function()
			vim.notify(("jdtls exited (code=%s, signal=%s)"):format(code, signal), vim.log.levels.ERROR)
		end)
	end,
	on_attach = function(_, buf)
		jdtls.setup_dap({ hotcodereplace = "auto" })
		require("jdtls.dap").setup_dap_main_class_configs()
		local m = function(l, r, d)
			vim.keymap.set("n", l, r, { buffer = buf, desc = d })
		end
		m("<leader>jo", jdtls.organize_imports, "Java: organize imports")
		m("<leader>jv", jdtls.extract_variable, "Java: extract variable")
		m("<leader>jm", jdtls.extract_method, "Java: extract method")
		m("<leader>jt", jdtls.test_nearest_method, "Java: test nearest")
		m("<leader>jT", jdtls.test_class, "Java: test class")
	end,
})
