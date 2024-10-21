local M = {}
local original_bg_color = nil

-- Save original Kitty background color
function M.save_original_kitty_background()
	local handle = io.popen("kitty @ get-colors")
	local result = handle:read("*a")
	handle:close()

	local bg_color = result:match("\nbackground%s+(#[0-9a-fA-F]+)")
	if bg_color then
		original_bg_color = bg_color
	end
end

-- Set Kitty background color based on Neovim's colorscheme
function M.set_kitty_background()
	local hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	if hl and hl.bg then
		local hex_bg_color = string.format("#%06x", hl.bg)
		os.execute("kitty @ set-colors background=" .. hex_bg_color)
	end
end

-- Restore original Kitty background color when exiting Neovim
function M.restore_kitty_background()
	if original_bg_color then
		os.execute("kitty @ set-colors background=" .. original_bg_color)
	end
end

function M.setup()
	-- Save original background when Neovim starts
	M.save_original_kitty_background()

	-- Update Kitty background when colorscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = M.set_kitty_background,
	})

	-- Restore original background when exiting Neovim
	vim.api.nvim_create_autocmd("VimLeave", {
		callback = M.restore_kitty_background,
	})
end

return M
