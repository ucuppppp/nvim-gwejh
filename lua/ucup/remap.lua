vim.g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- vim.keymap.set("n", "<leader>nh", vim.cmd.nohl)

if vim.g.vscode then
	-- VSCode Neovim
	require("ucup.vscode_remap")
else
	-- Ordinary Neovim
	vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
	vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

	vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
	vim.keymap.set("n", "<leader>wf", ":lua vim.lsp.buf.format()<CR>:w<CR>")

	-- enter visual mode then yank the line
	vim.keymap.set("n", "<leader>c", "V:y<CR>")

	-- yank to clipboard
	vim.keymap.set("v", "<leader>y", '"+y')

	-- tabpage
	-- vim.keymap.set({ "n", "v" }, "<leader>pn", ":tabnext<CR>")
	-- vim.keymap.set({ "n", "v" }, "<leader>pp", ":tabprev<CR>")
	-- vim.keymap.set({ "n", "v" }, "<leader>pc", ":tabnew<CR>")

	-- buffer next/prev
	vim.keymap.set("n", "<leader>pn", ":bnext<CR>")
	vim.keymap.set("n", "<leader>pb", ":bprev<CR>")
end
