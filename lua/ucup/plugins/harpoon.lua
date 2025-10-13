return {
	"ThePrimeagen/harpoon",
	enabled = false,
	branch = "harpoon2",
	dependencies = { { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" } },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		if not vim.g.vscode then
			vim.keymap.set("n", "<C-h>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end)
			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end)
		end
		-- vim.keymap.set("n", "<C-a>", function()
		-- 	harpoon:list():add()
		-- end)
		--
		-- vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
		-- vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
		-- vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
		-- vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<C-P>", function()
			harpoon:list():prev()
		end)
		vim.keymap.set("n", "<C-N>", function()
			harpoon:list():next()
		end)

		-- TELESCOPE
		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
				})
				:find()
		end

		vim.keymap.set("n", "<C-S-h>", function()
			toggle_telescope(harpoon:list())
		end, { desc = "Open harpoon window" })
	end,
}
