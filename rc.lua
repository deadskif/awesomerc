-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")

local os = require("os")

--local localrc = dofile(awful.util.getdir("config") .. "/" .. "localrc.lua")
-- package.loaded.localrc = false
local myrc = require("myrc")
--require('localrc')
--naughty.notify({ preset =  naughty.config.presets.critical,
--   title = "Localrc",
--    text =  " ___" .. tostring(myrc) .. "  " .. type(package.loaded.myrc)})
    --text =  " ___" .. type(localrc) .. ".." .. tostring(localrc)})

os.setlocale("LC_CTYPE=ru_RU.UTF-8;LC_NUMERIC=ru_RU.UTF-8;LC_TIME=ru_RU.UTF-8;LC_COLLATE=ru_RU.UTF-8;LC_MONETARY=ru_RU.UTF-8;LC_MESSAGES=ru_RU.UTF-8;LC_PAPER=ru_RU.UTF-8;LC_NAME=ru_RU.UTF-8;LC_ADDRESS=ru_RU.UTF-8;LC_TELEPHONE=ru_RU.UTF-8;LC_MEASUREMENT=ru_RU.UTF-8;LC_IDENTIFICATION=ru_RU.UTF-8")
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt +sb"
xlock = "slock"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
}
-- }}}

beautiful.wallpaper = myrc.wallpaper
--beautiful.wallpaper = wallpaper
-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        --gears.wallpaper.centered(beautiful.wallpaper, s)
        gears.wallpaper.maximized(beautiful.wallpaper, s)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {	
	names  = { 	"term",		"www",		"im",		"net",		5,
			6,		7,		"offs",		"adm" },
	layout = {	layouts[2],	layouts[3],	layouts[2],	layouts[3],	layouts[2],
			layouts[2],	layouts[2],	layouts[2],	layouts[2]
}}
for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

myinetmenu = {
	{ "Firefox", "firefox" },
	{ "Opera", "opera" },
	{ "Thunderbird", "thunderbird" },
	{ "EiskaltDC++-Gtk", "eiskaltdcpp-gtk" },
	{ "qBittorrent", "qbittorrent" },
	{ "QutIM", "qutim" }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
				    { "inet", myinetmenu },
				    { "ext env", "/home/skif/.bin/xinit_env.sh ext" },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
-- mytextclock = awful.widget.textclock({ align = "right" }, "%d %b %R")
mytextclock = awful.widget.textclock("%d %b %R")

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

local mywidgetupdatetime = 3

local mybatwidget = wibox.widget.textbox()

vicious.register(mybatwidget, vicious.widgets.bat,
	function(widget,args)
		local col = ""
		if args[1] == "-" then
			col = "#FF3030"
		else
			col = "#30FF30"
		end
		return "[<span color=\""..col.."\">"..args[2] .. "%" .. args[1].."</span>]"
 		end, mywidgetupdatetime, 'BAT0')
local mymemwidget = wibox.widget.textbox()
vicious.register(mymemwidget, vicious.widgets.mem, "$2Mb", mywidgetupdatetime)
--
local mycpuf0widget = wibox.widget.textbox()
vicious.register(mycpuf0widget, vicious.widgets.cpufreq, "$2$5", mywidgetupdatetime, "cpu0")
local mycpuf1widget = wibox.widget.textbox()
vicious.register(mycpuf1widget, vicious.widgets.cpufreq, "$2$5", mywidgetupdatetime, "cpu1")
local mycpuf2widget = wibox.widget.textbox()
vicious.register(mycpuf2widget, vicious.widgets.cpufreq, "$2$5", mywidgetupdatetime, "cpu2")
local mycpuf3widget = wibox.widget.textbox()
vicious.register(mycpuf3widget, vicious.widgets.cpufreq, "$2$5", mywidgetupdatetime, "cpu3")
--
local mythermwidget = wibox.widget.textbox()
vicious.register(mythermwidget, --vicious.widgets.thermal, 
	--function(format, warg) return 
	function(format, warg)
		local thermals = {}
		local t_inp = "/sys/class/hwmon/hwmon0/temp1_input"
		--local bpath, inputs = "/sys/class/hwmon/hwmon0", { "temp1_input", "temp3_input", "temp7_input" }
		--thermals = inputs
		--for i,k in ipairs(inputs) do
		local f = io.open(t_inp)
		if f then
			local s = f:read("*all")
			f:close()
			table.insert(thermals, s / 1000)
		else
			table.insert(thermals, "-")
		end
		--end
		return thermals
	end,
	"$1°", mywidgetupdatetime)
local mynetwidget = wibox.widget.textbox()
vicious.register(mynetwidget,
	function(format, warg)
		local bpath = "/sys/class/net/"
		local states = {}
		for i,k in ipairs(warg) do
			local f = io.open(bpath .. k .. "/operstate")
			if f then
				local s = f:read("*all")
				f:close()
				states[k] = s or "fail"
			else
				states[k] = "fail"
		--		table.insert(states, "-")
			end
			--states[k] = i
			--table.insert(states, k)
		end
		return states
	end, function(widget, arg)
		local s = ""
		for k,v in pairs(arg) do
			local n = ""
			local tt = { enp0s25 = "E", wlp3s0 = "W", lo = "0", ppp0 = "P", enp0s20u1 = "U" }
			k = tt[k] or "?"
			if v == "up\n" then
				n = "<span color=\"#30FF30\">" .. k .. "</span>"
			elseif v == "down\n" then
			--else
				n = "<span color=\"#FF3030\">" .. k .. "</span>"
			--else
			--	n = "?"
			end
			s = s .. n 
		end
		return "[" .. s .. "]"
	end, mywidgetupdatetime, { "wlp3s0", "enp0s25", "enp0s20u1" });
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(mybatwidget)
    right_layout:add(mythermwidget)
    right_layout:add(mynetwidget)
    right_layout:add(mymemwidget)
    --right_layout:add(mycpuf0widget)
    --right_layout:add(mycpuf1widget)
    --right_layout:add(mycpuf2widget)
    --right_layout:add(mycpuf3widget)
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control", "Shift" }, "l",     function () awful.util.spawn(xlock)	end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Opera" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][4] } },
    { rule = { instance = "qbittorrent" },
      properties = { tag = tags[1][4] } },
    { rule = { instance = "eiskaltdcpp-gtk" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Qutim" },
      properties = { tag = tags[1][3] } },
    { rule = { class = "Claws-mail" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "LibreOffice" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "Xpdf" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "MuPDF" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "Epdfview" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "Djview" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "Wpa_gui" },
      properties = { floating = true } },
    { rule = { class = "Mytetra" },
      properties = { tag = tags[1][9], maximized_horizontal = true, maximized_vertical = true } },


}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

if myrc.post_spawn then
    myrc.post_spawn()
end
-- }}}
