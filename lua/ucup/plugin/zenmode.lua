return {
	"folke/zen-mode.nvim",
	opts = {
		window = {
			width = 90,
		},
	},
	config = function()
		vim.keymap.set("n", "<leader>pz", function()
			require("zen-mode").toggle({
				window = {
					width = 0.85, -- width will be 85% of the editor width
				},
				plugins = {
					wezterm = {
						enabled = true,
						-- can be either an absolute font size or the number of incremental steps
						font = "", -- (10% increase per step)
					},
				},
			})
		end)
	end,
}
