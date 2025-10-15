return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",
	dependencies = {
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "neovim/nvim-lspconfig" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lsp-signature-help" },
		{ "L3MON4D3/LuaSnip", version = "v2.*", dependencies = { "rafamadriz/friendly-snippets" } },
		{ "lukas-reineke/lsp-format.nvim" },
		{ "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" },
		{ "onsails/lspkind.nvim" },
	},
	config = function()
		vim.o.winborder = "rounded"

		-- Folding
		vim.o.foldcolumn = "1"
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		vim.keymap.set("n", "zR", require("ufo").openAllFolds)
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

		-- Capabilities untuk folding
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}

		-- Setup ufo
		require("ufo").setup()

		-- LSP Zero setup
		local lsp_zero = require("lsp-zero")
		local cmp = require("cmp")
		local cmp_action = lsp_zero.cmp_action()

		lsp_zero.on_attach(function(client, bufnr)
			lsp_zero.default_keymaps({ buffer = bufnr })
		end)

		require("luasnip.loaders.from_vscode").lazy_load()
		require("mason").setup({})

		-- Mason-lspconfig dengan vim.lsp.config (Neovim 0.11+)
		require("mason-lspconfig").setup({
			handlers = {
				-- Default handler untuk semua server
				function(server_name)
					vim.lsp.config[server_name] = {
						capabilities = capabilities,
					}
				end,
				-- Handler khusus untuk yamlls
				["yamlls"] = function()
					vim.lsp.config.yamlls = {
						capabilities = capabilities,
						settings = {
							yaml = {
								schemas = {
									kubernetes = "/*.yaml",
								},
							},
						},
					}
				end,
				-- Handler khusus untuk volar
				["volar"] = function()
					vim.lsp.config.volar = {
						capabilities = capabilities,
						filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
					}
				end,
			},
		})

		-- Completion setup
		cmp.setup({
			sources = {
				{ name = "luasnip" },
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-f>"] = cmp_action.luasnip_jump_forward(),
				["<C-b>"] = cmp_action.luasnip_jump_backward(),
				["<C-u>"] = cmp.mapping.scroll_docs(-4),
				["<C-d>"] = cmp.mapping.scroll_docs(4),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<C-p>"] = cmp.mapping(function()
					if cmp.visible() then
						cmp.select_prev_item({ behavior = "insert" })
					else
						cmp.complete()
					end
				end),
				["<C-n>"] = cmp.mapping(function()
					if cmp.visible() then
						cmp.select_next_item({ behavior = "insert" })
					else
						cmp.complete()
					end
				end),
			}),
			formatting = {
				fields = { "abbr", "kind", "menu" },
				format = require("lspkind").cmp_format({
					mode = "symbol",
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},
		})
	end,
}
