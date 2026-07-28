-- scripts/shared/ui_helpers.lua

local ui_helpers = {}

function ui_helpers.set_alpha(node_name, alpha)
	gui.set_alpha(gui.get_node(node_name), alpha)
end

function ui_helpers.toggle_pair(on_node, off_node, is_on)
	gui.set_alpha(gui.get_node(on_node),  is_on and 1 or 0.3)
	gui.set_alpha(gui.get_node(off_node), is_on and 0.3 or 1)
end

function ui_helpers.set_color(node_name, color)
	gui.set_color(gui.get_node(node_name), color)
end

function ui_helpers.is_node_pressed(node_name, x, y)
	return gui.pick_node(gui.get_node(node_name), x, y)
end

return ui_helpers