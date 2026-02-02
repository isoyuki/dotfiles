local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local splitcolumns = {}

splitcolumns.name = "splitcolumns"

function splitcolumns.arrange(p)
	local clients = p.clients
	local n = #clients
	local wa = p.workarea

	if n == 0 then
		return
	end

	if n == 1 then
		awful.client.set_geometry(clients[1], {
			x = wa.x,
			y = wa.y,
			width = wa.width,
			height = wa.height,
		})
		return
	end

	local num_cols
	if n <= 2 then
		num_cols = n
	elseif n <= 4 then
		num_cols = 2
	elseif n <= 6 then
		num_cols = 3
	else
		-- For more than 6 clients, cycle through 2 and 3 column layouts
		if n % 3 == 0 then
			num_cols = 3
		else
			num_cols = 2
		end
	end

	local col_width = wa.width / num_cols
	local client_idx = 1

	for i = 1, num_cols do
		local clients_in_col = {}
		if i <= n % num_cols then
			for j = 1, math.ceil(n / num_cols) do
				if clients[client_idx] then
					table.insert(clients_in_col, clients[client_idx])
					client_idx = client_idx + 1
				end
			end
		else
			for j = 1, math.floor(n / num_cols) do
				if clients[client_idx] then
					table.insert(clients_in_col, clients[client_idx])
					client_idx = client_idx + 1
				end
			end
		end

		local num_clients_in_col = #clients_in_col
		if num_clients_in_col > 0 then
			local row_height = wa.height / num_clients_in_col
			for j, c in ipairs(clients_in_col) do
				awful.client.set_geometry(c, {
					x = wa.x + (i - 1) * col_width,
					y = wa.y + (j - 1) * row_height,
					width = col_width,
					height = row_height,
				})
			end
		end
	end
end

-- Create the layout table
local layout = {
	name = splitcolumns.name,
	arrange = splitcolumns.arrange,
	-- This icon will be displayed in your layout box
	-- icon = beautiful.awesome_icon
}

return layout
