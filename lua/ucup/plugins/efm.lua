local function usePrettier(fs, executable)
	return {
		formatCanRange = true,
		formatCommand = string.format(
			"%s '${INPUT}' ${--range-start=charStart} ${--range-end=charEnd} ",
			-- .. "${--tab-width=tabWidth} ${--use-tabs=!insertSpaces}",
			fs.executable(executable, fs.Scope.NODE)
		),
		formatStdin = true,
		rootMarkers = {
			"package.json",
			".prettierrc",
			".prettierrc.json",
			".prettierrc.js",
			".prettierrc.yml",
			".prettierrc.yaml",
			".prettierrc.json5",
			".prettierrc.mjs",
			".prettierrc.cjs",
			".prettierrc.toml",
			"prettier.config.js",
			"prettier.config.cjs",
			"prettier.config.mjs",
		},
	}
end

return {
	"creativenull/efmls-configs-nvim",
	version = "v1.7.0",
	dependencies = {
		require("ucup.plugins.lsp"),
		"neovim/nvim-lspconfig",
	},

	config = function()
		-- Formatters
		local fs = require("efmls-configs.fs")
		local lsp_format = require("lsp-format")

		local prettier = usePrettier(fs, "prettier") -- or prettierd
		local djlintHbs = {
			formatCommand = string.format(
				"%s --reformat --profile=handlebars --indent 3 - '${INPUT}'",
				fs.executable("djlint")
			),
			formatStdin = true,
		}
		local eslint_d = require("efmls-configs.linters.eslint_d")
		local astyle = require("efmls-configs.formatters.astyle")

		local languages = require("efmls-configs.defaults").languages()
		languages = vim.tbl_extend("force", languages, {
			-- Custom languages, or override existing ones
			html = { prettier },
			toml = { prettier },
			typescript = { prettier },
			javascript = { prettier },
			typescriptreact = { prettier },
			javascriptreact = { prettier },
			vue = { prettier },
			handlebars = { djlintHbs },
			json = { prettier },
			jsonc = { prettier },
			lua = { require("efmls-configs.formatters.stylua") },
			go = { require("efmls-configs.formatters.gofumpt") },
			c = { astyle },
			cpp = { astyle },
		})
		local efmls_config = {
			filetypes = vim.tbl_keys(languages),
			settings = {
				rootMarkers = { ".git/" },
				languages = languages,
			},
			init_options = {
				documentFormatting = true,
				documentRangeFormatting = true,
			},
		}

		vim.lsp.config["efm"] = vim.tbl_extend("force", efmls_config, {
			on_attach = lsp_format.on_attach,
		})
	end,
}
