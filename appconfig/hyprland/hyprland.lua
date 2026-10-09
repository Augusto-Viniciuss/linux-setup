-- Hyprland 0.55+, keeping the Alt-based controls from appconfig/i3/doti3/config_git.
local terminal = "kitty"
local launcher = "rofi -combi-modi drun,run -show combi -opacity '85' -width 100 -padding 200 -font 'Monospace 18' -lines 10 -eh 1"
local mod = "ALT"

hl.config({
    general = {
        gaps_in = 12,
        gaps_out = 0,
        border_size = 3,
        col = {
            active_border = "rgba(005fafff)",
            inactive_border = "rgba(333333ff)",
        },
        layout = "dwindle",
        resize_on_border = true,
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur = { enabled = false },
    },
    dwindle = { preserve_split = true },
    input = {
        kb_layout = "us,cz",
        kb_variant = ",qwerty",
        kb_options = "grp:rctrl_rshift_toggle,caps:escape",
        follow_mouse = 0,
        repeat_rate = 55,
        repeat_delay = 350,
    },
})

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("~/.config/hypr/apply-layout.sh")
    hl.exec_cmd("~/.config/hypr/apply-theme.sh")
end)

-- Terminal, close, and launcher.
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + D", hl.dsp.exec_cmd(launcher))

-- Move focus and windows with the same h/j/k/l keys as i3.
local directions = {
    { key = "H", direction = "left" },
    { key = "J", direction = "down" },
    { key = "K", direction = "up" },
    { key = "L", direction = "right" },
}
for _, item in ipairs(directions) do
    hl.bind(mod .. " + " .. item.key, hl.dsp.focus({ direction = item.direction }))
    hl.bind(mod .. " + SHIFT + " .. item.key, hl.dsp.window.move({ direction = item.direction }))
end

hl.bind("ALT + TAB", hl.dsp.exec_cmd("hyprctl dispatch cyclenext"))
hl.bind(mod .. " + X", hl.dsp.exec_cmd("hyprctl dispatch moveworkspacetomonitor +1"))
hl.bind(mod .. " + braceleft", hl.dsp.layout("preselect l"))
hl.bind(mod .. " + braceright", hl.dsp.layout("preselect r"))
hl.bind(mod .. " + N", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + M", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))

-- Fullscreen, layout, floating, focus history, and the i3-style scratchpad.
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + S", hl.dsp.exec_cmd("hyprctl keyword general:layout master"))
hl.bind(mod .. " + W", hl.dsp.group.toggle())
hl.bind(mod .. " + E", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + Q", hl.dsp.group.next())
hl.bind(mod .. " + A", hl.dsp.layout("movetoroot"))
hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("hyprctl dispatch focuscurrentorlast"))
hl.bind(mod .. " + minus", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Workspaces 1-10, where 0 selects workspace 10.
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + SHIFT + C", hl.dsp.reload_config())
hl.bind(mod .. " + SHIFT + R", hl.dsp.reload_config())
hl.bind("SUPER + D", hl.dsp.exec_cmd(launcher))
hl.bind("SUPER + F", hl.dsp.exec_cmd("~/.config/hypr/system-menu.sh"))
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("~/.config/hypr/system-menu.sh"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("~/.config/hypr/gpu-menu.sh"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("~/.config/hypr/theme-menu.sh"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("~/.config/hypr/layout-menu.sh"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("~/.config/hypr/toggle-touchpad.sh"))

-- Optional Gazebo controls used by the robotics profiles.
for i = 1, 5 do
    hl.bind("SUPER + " .. i, hl.dsp.exec_cmd("gz camera -c gzclient_camera -f uav" .. i))
end
hl.bind("SUPER + P", hl.dsp.exec_cmd("gz world -p 1"))
hl.bind("SUPER + U", hl.dsp.exec_cmd("gz world -p 0"))
hl.bind("SUPER + I", hl.dsp.exec_cmd("gz world -m 100"))

-- Audio controls retain the Mod4 + F5..F8 shortcuts from i3.
hl.bind("SUPER + F5", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%"), { repeating = true })
hl.bind("SUPER + F6", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%"), { repeating = true })
hl.bind("SUPER + F7", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("SUPER + F8", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ 100%"))
hl.bind("SUPER + F1", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 10%-"), { repeating = true })
hl.bind("SUPER + F2", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 10%+"), { repeating = true })
hl.bind("SUPER + F3", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 2%"))
hl.bind("SUPER + F4", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 100%"))

-- Resize mode, entered with Alt+R. Escape or Return returns to normal mode.
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    for _, item in ipairs(directions) do
        local x = item.direction == "left" and -20 or item.direction == "right" and 20 or 0
        local y = item.direction == "up" and -20 or item.direction == "down" and 20 or 0
        hl.bind(item.key, hl.dsp.window.resize({ x = x, y = y, relative = true }), { repeating = true })
    end
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Keep i3's adjustable gaps mode (Alt+Shift+G, then +/-/0/d).
local inner_gap = 12
hl.bind(mod .. " + SHIFT + G", hl.dsp.submap("gaps"))
hl.define_submap("gaps", function()
    hl.bind("plus", function()
        inner_gap = inner_gap + 5
        hl.exec_cmd("hyprctl keyword general:gaps_in " .. inner_gap)
    end, { repeating = true })
    hl.bind("minus", function()
        inner_gap = math.max(0, inner_gap - 5)
        hl.exec_cmd("hyprctl keyword general:gaps_in " .. inner_gap)
    end, { repeating = true })
    hl.bind("0", function()
        inner_gap = 0
        hl.exec_cmd("hyprctl keyword general:gaps_in 0")
        hl.exec_cmd("hyprctl keyword general:gaps_out 0")
        hl.exec_cmd("hyprctl dispatch submap reset")
    end)
    hl.bind("D", function()
        inner_gap = 12
        hl.exec_cmd("hyprctl keyword general:gaps_in 12")
        hl.exec_cmd("hyprctl keyword general:gaps_out 0")
        hl.exec_cmd("hyprctl dispatch submap reset")
    end)
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Modifier + mouse keeps i3's move and resize gestures.
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Wayland-native screenshots; volume/brightness multimedia keys work on laptops.
hl.bind("Print", hl.dsp.exec_cmd("~/.config/hypr/screenshot.sh"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.window_rule({ name = "pdfpc-no-border", match = { class = "pdfpc" }, border_size = 0 })
