return {
	"tpope/vim-fugitive",
	config = function()
		-- Git status
		vim.keymap.set("n", "<leader>gs", function()
			vim.cmd("Git")
		end, { desc = "Git Status (Fugitive)" })

		-- Git diff
		vim.keymap.set("n", "<leader>gd", function()
			vim.cmd("Gdiffsplit")
		end, { desc = "Git Diff (Fugitive)" })

		-- Load konfigurasi tambahan (kalau ada)
		require("ucup.plugin.fugitive")
	end,
}
