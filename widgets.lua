local wibox = require("wibox")
local vicious = require("vicious")
local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local io = require("io")
local widgets = {}

local mywidgetupdatetime = 3

--widgets.mem = wibox.widget.textbox()
--vicious.register(widgets.mem, vicious.widgets.mem, "$2Mb,$6Mb", mywidgetupdatetime)

function cpuf(widget, data)
    local percentage = math.floor(data[2] * 10) / 10
    return percentage .. "GHz" .. data[5]
end

beautiful.tooltip_bg = "#3F3F3F"
beautiful.tooltip_fg = "#CC9393"
widgets.cpuf0 = wibox.widget.textbox()
vicious.register(widgets.cpuf0, vicious.widgets.cpufreq, cpuf, mywidgetupdatetime, "cpu0")

widgets.cpuf1 = wibox.widget.textbox()
vicious.register(widgets.cpuf1, vicious.widgets.cpufreq, cpuf, mywidgetupdatetime, "cpu1")

widgets.cpuf2 = wibox.widget.textbox()
vicious.register(widgets.cpuf2, vicious.widgets.cpufreq, cpuf, mywidgetupdatetime, "cpu2")

widgets.cpuf3 = wibox.widget.textbox()
vicious.register(widgets.cpuf3, vicious.widgets.cpufreq, cpuf, mywidgetupdatetime, "cpu3")

widgets.cpugraph = wibox.widget.graph()
widgets.cpugraph:set_stack(true)
widgets.cpugraph:set_stack_colors({"red", "yellow", "green", "blue"})
vicious.register(widgets.cpugraph, vicious.widgets.cpu,
                 function (widget, args)
                     return {args[2], args[3], args[4], args[5]}
                 end, 3)

widgets.mem = wibox.widget {
   {
       max_value        = 1,
       value            = 0.10,
       background_color = beautiful.bg_normal or "#3F3F3F",
       color            = {type="linear", from = {0, 0}, to = {0, 20},
            stops = { {0, "#F6F6F6"}, {0.5, 
            "#bdbdbd"}, {1.0, "#3b3b3b"} }
       },
       widget           = wibox.widget.progressbar,
   },
   forced_width     = 5,
   forced_height    = 10,
   direction        = 'east',
   layout           = wibox.container.rotate
}

local mem_t = awful.tooltip({ objects = { widgets.mem }})
function vicious_formatter_memory(widget, data)
    local memory_percentage = math.floor(((data[2] / data[3]) * 100) + 0.5)
    local tooltip_text = string.format('Current memory usage: %d%% (%dMB out of %dMB) ', memory_percentage, data[2], data[3])
    mem_t:set_text(tooltip_text)
    return memory_percentage
end
vicious.register(widgets.mem:get_all_children()[1],vicious.widgets.mem, vicious_formatter_memory, mywidgetupdatetime)


widgets.swap = wibox.widget {
   {
       max_value        = 1,
       value            = 0.10,
       --background_color = "#131211",
       background_color = beautiful.bg_focus or "#3F3F3F",
       color            = {type="linear", from = {0, 0}, to = {0, 20},
            stops = { {0, "#F6F6F6"}, {0.5, 
            "#bdbdbd"}, {1.0, "#3b3b3b"} }
       },
       widget           = wibox.widget.progressbar,
   },
   forced_width     = 5,
   forced_height    = 10,
   direction        = 'east',
   layout           = wibox.container.rotate
}
local swap_t = awful.tooltip({ objects = { widgets.swap }, fg = '#00ff00', bg = '#000000' })
-- Vicious display formatter for swap graph
function vicious_formatter_swap(widget, data)
    local swap_percentage = math.floor(((data[6] / data[7]) * 100) + 0.5)
    local tooltip_text = string.format('Current swap usage: %d%% (%dMB out of %dMB)', swap_percentage, data[6], data[7])
    swap_t:set_text(tooltip_text)
    return (data[6] / data[7])*100
end

vicious.register(widgets.swap:get_all_children()[1], vicious.widgets.mem, vicious_formatter_swap, mywidgetupdatetime)

widgets.net = wibox.widget.textbox()
vicious.register(widgets.net,
	function(format, warg)
		local states = {}
		local bpath = "/sys/class/net/"
        for line in io.lines("/proc/net/dev") do
            local name = string.match(line, "^[%s]?[%s]?[%s]?[%s]?([%w]+):")
            if name ~= nil then
                local f = io.open(bpath .. name .. "/operstate")
                if f then
                    local s = f:read("*all")
                    f:close()
                    states[name] = s or "fail"
                else
                    states[name] = "fail"
                end
            end
		end
		return states
	end, function(widget, arg)
		local s = ""
		for k,v in pairs(arg) do
			local n = ""
            if k == "lo" then
                k = "➰"
            end
			k = string.upper(string.sub(k, 1, 1))
			if v == "up\n" then
				n = "<span color=\"#30FF30\">" .. k .. "</span>"
			elseif v == "down\n" then
				n = "<span color=\"#FF3030\">" .. k .. "</span>"
			end
			s = s .. n 
		end
		return "[" .. s .. "]"

	end, mywidgetupdatetime);

return widgets
