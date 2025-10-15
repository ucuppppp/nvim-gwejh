local function usePrettier(fs, executable)
	return {
		formatCommand = table.concat({
			fs.executable(executable, fs.Scope.NODE),
			"--stdin-filepath '${INPUT}'",
			"--stdin",
		}, " "),
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
		"neovim/nvim-lspconfig",
		"lukas-reineke/lsp-format.nvim",
	},
	config = function()
		local lsp_format = require("lsp-format")
		local fs = require("efmls-configs.fs")

		lsp_format.setup({
			sync = true,
		})

		-- Formatter configurations
		local prettier = usePrettier(fs, "prettier")
		local djlintHbs = {
			formatCommand = string.format(
				"%s --reformat --profile=handlebars --indent 3 -",
				fs.executable("djlint", fs.Scope.SYSTEM)
			),
			formatStdin = true,
		}

		-- Import formatters/linters dengan error handling
		local ok_eslint, eslint_d = pcall(require, "efmls-configs.linters.eslint_d")
		local ok_astyle, astyle = pcall(require, "efmls-configs.formatters.astyle")
		local ok_stylua, stylua = pcall(require, "efmls-configs.formatters.stylua")
		local ok_gofumpt, gofumpt = pcall(require, "efmls-configs.formatters.gofumpt")

		-- Base language config
		local languages = require("efmls-configs.defaults").languages()

		-- Extend languages (hanya yang tersedia)
		local custom_languages = {
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
			yaml = { prettier },
			markdown = { prettier },
			css = { prettier },
			scss = { prettier },
		}

		-- Add optional formatters jika tersedia
		if ok_stylua then
			custom_languages.lua = { stylua }
		end
		if ok_gofumpt then
			custom_languages.go = { gofumpt }
		end
		if ok_astyle then
			custom_languages.c = { astyle }
			custom_languages.cpp = { astyle }
		end

		languages = vim.tbl_extend("force", languages, custom_languages)

		-- Custom on_attach
		local function on_attach(client, bufnr)
			lsp_format.on_attach(client, bufnr)

			if client.server_capabilities.documentFormattingProvider then
				-- Keymap untuk manual format
				vim.keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format({ async = false })
				end, { buffer = bufnr, desc = "Format buffer" })

				-- Format on save (alternatif jika lsp-format tidak bekerja)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					 callback = function()
						vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000, async = false })
					end,
				})
			end
		end

		-- Setup EFM untuk Neovim 0.11+
		local efm_config = {
			cmd = { "efm-langserver" },
			filetypes = vim.tbl_keys(languages),
			root_dir = function(fname)
				return vim.fs.root(fname, { ".git" }) or vim.fn.getcwd()
			end,
			settings = {
				rootMarkers = { ".git/" },
				languages = languages,
			},
			init_options = {
				documentFormatting = true,
				documentRangeFormatting = true,
			},
			on_attach = on_attach,
		}

		-- Check Neovim version untuk API yang tepat
		if vim.fn.has("nvim-0.11") == 1 then
			-- Neovim 0.11+
			vim.lsp.config.efm = efm_config
		else
			-- Neovim < 0.11 (fallback ke lspconfig)
			local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
			if lspconfig_ok then
				lspconfig.efm.setup(efm_config)
			end
		end

		-- Auto-start EFM untuk filetypes yang didukung
		vim.api.nvim_create_autocmd("FileType", {
			pattern = vim.tbl_keys(languages),
			callback = function(args)
				vim.lsp.start({ name = "efm", bufnr = args.buf })
			end,
		})
	end,
}
