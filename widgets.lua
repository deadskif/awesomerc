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
       color            = {type="linear", from = {0, 0}, to = {20, 0},
            --stops = { {0, "#F6F6F6"}, {0.5, 
            --"#bdbdbd"}, {1.0, "#3b3b3b"} }
            stops = { {0, "#008000"}, {0.5, "#FFA500"}, {1.0, "#ff0000"}}
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
    local memory_percentage = math.floor(((data[9] / data[3]) * 100) + 0.5)
    local tooltip_text = string.format('Memory usage: %d%% (%dMB out of %dMB)\n'
                .. 'Memory (with buffers and cache) usage: %d%%(%dMB out of %dMB)',
                data[1], data[2], data[3], memory_percentage, data[9], data[3])
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
       color            = {type="linear", from = {0, 0}, to = {20, 0},
            --stops = { {0, "#F6F6F6"}, {0.5, 
            --"#bdbdbd"}, {1.0, "#3b3b3b"} }
            stops = { {0, "#008000"}, {0.5, "#FFA500"}, {1.0, "#ff0000"}}
       },
       widget           = wibox.widget.progressbar,
   },
   forced_width     = 5,
   forced_height    = 10,
   direction        = 'east',
   layout           = wibox.container.rotate
}
local swap_t = awful.tooltip({ objects = { widgets.swap }})
-- Vicious display formatter for swap graph
function vicious_formatter_swap(widget, data)
    local swap_percentage = math.floor(((data[6] / data[7]) * 100) + 0.5)
    local tooltip_text = string.format('Current swap usage: %d%% (%dMB out of %dMB)', swap_percentage, data[6], data[7])
    swap_t:set_text(tooltip_text)
    return (data[6] / data[7])*100
end

vicious.register(widgets.swap:get_all_children()[1], vicious.widgets.mem, vicious_formatter_swap, mywidgetupdatetime)

widgets.net = wibox.widget.textbox()
local net_t = awful.tooltip({ objects = { widgets.net }})
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
                    states[name] = string.gsub(s, "\n", "") or "fail"
                else
                    states[name] = "fail"
                end
            end
		end
		return states
	end, function(widget, arg)
		local s = ""
        local t = "Interfaces:"
		for k,v in pairs(arg) do
			local n = ""
            t = t .. "\n" .. k .. " " .. v 
			k = string.upper(string.sub(k, 1, 1))
			if v == "up" then
				n = "<span color=\"#30FF30\">" .. k .. "</span>"
			elseif v == "down" then
				n = "<span color=\"#FF0000\">" .. k .. "</span>"
			end
			s = s .. n 
		end
        net_t:set_text(t)
		return "[" .. s .. "]"

	end, mywidgetupdatetime);

--widgets.bat = wibox.widget.textbox()
--vicious.register(widgets.bat, vicious.widgets.bat, "$2%$1", mywidgetupdatetime, "BAT0")
return widgets
