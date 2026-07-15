local M = {}

function M.fade_in(node, duration)
	local color = gui.get_color(node)
	color.w = 0
	gui.set_color(node, color)
	gui.animate(node, gui.PROP_COLOR, vmath.vector4(color.x, color.y, color.z, 1), 
	gui.EASING_OUT, duration or 0.3, 0)
end

function M.fade_out(node, duration, callback)
	local color = gui.get_color(node)
	gui.animate(node, gui.PROP_COLOR, vmath.vector4(color.x, color.y, color.z, 0),
	gui.EASING_OUT, duration or 0.3, 0, callback)
end

function M.pulse(node, color, duration)
	gui.animate(node, gui.PROP_COLOR, color, gui.EASING_OUT, duration or 0.15, 0, function()
		gui.animate(node, gui.PROP_SCALE, vmath.vector3(1.05, 1.05, 1), gui.EASING_OUT, 0.1, 0, function()
			gui.animate(node, gui.PROP_SCALE, vmath.vector3(1, 1, 1), gui.EASING_OUT, 0.1, 0)
		end)
	end)
end

function M.shake(node)
	local pos = gui.get_position(node)
	gui.animate(node, gui.PROP_POSITION, vmath.vector3(pos.x + 10, pos.y, pos.z), gui.EASING_OUT, 0.05, 0, function()
		gui.animate(node, gui.PROP_POSITION, vmath.vector3(pos.x - 10, pos.y, pos.z), gui.EASING_OUT, 0.05, 0, function()
			gui.animate(node, gui.PROP_POSITION, vmath.vector3(pos.x + 6, pos.y, pos.z), gui.EASING_OUT, 0.05, 0, function()
				gui.animate(node, gui.PROP_POSITION, vmath.vector3(pos.x, pos.y, pos.z), gui.EASING_OUT, 0.05, 0)
			end)
		end)
	end)
end

function M.hover_in(node, color, size)
	gui.animate(node, gui.PROP_COLOR, color, gui.EASING_OUT, 0.1, 0)
	gui.animate(node, gui.PROP_SCALE, size or vmath.vector3(1.03, 1.03, 1), gui.EASING_OUT, 0.1, 0)
end

function M.hover_out(node, color, size)
	gui.animate(node, gui.PROP_COLOR, color, gui.EASING_OUT, 0.1, 0)
	gui.animate(node, gui.PROP_SCALE, size or vmath.vector3(1, 1, 1), gui.EASING_OUT, 0.1, 0)
end

function M.screen_in(node)
	local pos = gui.get_position(node)
	gui.set_position(node, vmath.vector3(pos.x, pos.y - 50, pos.z))
	local color = gui.get_color(node)
	color.w = 0
	gui.set_color(node, color)
	gui.animate(node, gui.PROP_POSITION, vmath.vector3(pos.x, pos.y, pos.z), gui.EASING_OUTBACK, 0.3, 0)
	gui.animate(node, gui.PROP_COLOR, vmath.vector4(color.x, color.y, color.z, 1), gui.EASING_OUT, 0.3, 0)
end

return M