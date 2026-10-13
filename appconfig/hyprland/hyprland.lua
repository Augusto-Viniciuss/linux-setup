-- Hyprland 0.55+ profile. Preserve the Alt/Mod1 workflow from i3.
local start_app = "linux-setup-hyprland-app"
local terminal = start_app .. " kitty"
local launcher = start_app .. " rofi -combi-modes drun,run -show combi -width 100 -padding 200 -font 'Monospace 18' -lines 10 -eh 1"
local mod = "ALT"
local inner_gap = 12
local outer_gap = 0

hl.config({
    general = {
        gaps_in = inner_gap,
        gaps_out = outer_gap,
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
        shadow = { enabled = true, range = 12, render_power = 3, color = "rgba(000000bf)" },
        blur = { enabled = false },
    },
    dwindle = { preserve_split = true },
    group = {
        auto_group = false,
        groupbar = {
            enabled = true,
            stacked = false,
            height = 18,
            font_family = "Terminus",
            font_size = 10,
            render_titles = true,
            gradients = false,
            col = {
                active = "rgba(005fafff)",
                inactive = "rgba(333333ff)",
            },
        },
    },
    input = {
        kb_layout = "us,cz",
        kb_variant = ",qwerty",
        kb_options = "grp:rctrl_rshift_toggle,caps:escape",
        follow_mouse = 0,
        repeat_rate = 55,
        repeat_delay = 350,
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },
    xwayland = { enabled = true },
})

-- Hyprland 0.55.4's default spring transitions feel sluggish on this setup.
-- Use predictable 100 ms Bézier timings for window, layer and workspace changes.
hl.curve("linuxSetupQuick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("linuxSetupLinear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.animation({ leaf = "global", enabled = true, speed = 1, bezier = "linuxSetupQuick" })
hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "linuxSetupQuick", style = "popin 95%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, bezier = "linuxSetupQuick", style = "popin 95%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "linuxSetupLinear", style = "popin 95%" })
hl.animation({ leaf = "layers", enabled = true, speed = 1, bezier = "linuxSetupQuick" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1, bezier = "linuxSetupQuick", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1, bezier = "linuxSetupLinear", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "linuxSetupQuick", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1, bezier = "linuxSetupQuick", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1, bezier = "linuxSetupQuick", style = "fade" })

-- i3-gaps smart_gaps: remove gaps only for a workspace with one tiled window.
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE XDG_DATA_DIRS")
    hl.exec_cmd("~/.config/hypr/wallpaper.sh")
    hl.exec_cmd("~/.config/hypr/start-notifyd.sh")
    hl.exec_cmd("~/.config/hypr/start-session-ui.sh")
end)

-- Terminal, close, and Rofi's application+command search.
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + D", hl.dsp.exec_cmd(launcher))

-- Focus and move tiled windows with the same h/j/k/l keys as i3.
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

hl.bind(mod .. " + TAB", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + X", hl.dsp.workspace.move({ monitor = "r" }))
-- i3 split h/v map to Hyprland's next-window left/right and down directions.
hl.bind(mod .. " + braceleft", hl.dsp.layout("preselect d"))
hl.bind(mod .. " + braceright", hl.dsp.layout("preselect r"))
-- i3 next_on_output / prev_on_output: cycle on this monitor, including empty IDs.
hl.bind(mod .. " + N", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + M", hl.dsp.focus({ workspace = "m-1" }))
-- Waybar SIGUSR1 toggles visibility, matching i3's bar mode toggle.
hl.bind(mod .. " + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))

-- Hyprland has no i3-style workspace-wide tabbed/stacked modes. Groups provide
-- tabs for selected windows; master is the closest built-in stacked layout.
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + S", function()
    hl.config({ general = { layout = "master" }, group = { groupbar = { stacked = true } } })
end)
hl.bind(mod .. " + W", hl.dsp.group.toggle())
hl.bind(mod .. " + E", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + Q", hl.dsp.group.next())
hl.bind(mod .. " + A", hl.dsp.group.prev())
hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
-- i3 focus mode_toggle: switch focus between tiled and floating windows.
hl.bind(mod .. " + SPACE", function()
    local window = hl.get_active_window()
    if not window then return end
    hl.dispatch(hl.dsp.window.cycle_next({ floating = not window.floating, tiled = window.floating }))
end)
hl.bind(mod .. " + minus", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Workspace numbers and move-window counterparts match i3's 1..10 keys.
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Keep the existing Super-key utilities, and preserve the i3 shutdown chord too.
hl.bind("SUPER + D", hl.dsp.exec_cmd(launcher))
hl.bind("SUPER + F", hl.dsp.exec_cmd("~/.config/hypr/system-menu.sh"))
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("~/.config/hypr/system-menu.sh"))
hl.bind(mod .. " + SHIFT + X", hl.dsp.exec_cmd("~/.config/hypr/system-menu.sh"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("~/.config/hypr/gpu-menu.sh"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("~/.config/hypr/theme-menu.sh"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("~/.config/hypr/layout-menu.sh"))
hl.bind(mod .. " + T", hl.dsp.exec_cmd("~/.config/hypr/toggle-touchpad.sh"))

-- Optional Gazebo shortcuts remain available when the user has ROS/Gazebo installed.
for i = 1, 5 do
    hl.bind("SUPER + " .. i, hl.dsp.exec_cmd("gz camera -c gzclient_camera -f uav" .. i))
end
hl.bind("SUPER + P", hl.dsp.exec_cmd("gz world -p 1"))
hl.bind("SUPER + U", hl.dsp.exec_cmd("gz world -p 0"))
hl.bind("SUPER + I", hl.dsp.exec_cmd("gz world -m 100"))

-- Preserve i3's Mod1 (Alt) audio and brightness keys.
hl.bind(mod .. " + F5", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%"), { repeating = true })
hl.bind(mod .. " + F6", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%"), { repeating = true })
hl.bind(mod .. " + F7", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind(mod .. " + F8", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ 100%"))
hl.bind(mod .. " + F1", hl.dsp.exec_cmd("~/.config/hypr/brightness.sh -"), { repeating = true })
hl.bind(mod .. " + F2", hl.dsp.exec_cmd("~/.config/hypr/brightness.sh +"), { repeating = true })
hl.bind(mod .. " + F3", hl.dsp.exec_cmd("~/.config/hypr/brightness.sh 2"))
hl.bind(mod .. " + F4", hl.dsp.exec_cmd("~/.config/hypr/brightness.sh 100"))

-- Resize mode: symmetric h/j/k/l steps, one-axis Shift variants and 10px arrows.
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("h", hl.dsp.window.resize({ x = -2, y = 0, relative = true }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = -2, relative = true }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = 2, relative = true }), { repeating = true })
    hl.bind("l", hl.dsp.window.resize({ x = 2, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + H", hl.dsp.window.resize({ x = 1, y = 0, relative = true }), { repeating = true })
    hl.bind("SHIFT + J", hl.dsp.window.resize({ x = 0, y = 1, relative = true }), { repeating = true })
    hl.bind("SHIFT + K", hl.dsp.window.resize({ x = 0, y = 1, relative = true }), { repeating = true })
    hl.bind("SHIFT + L", hl.dsp.window.resize({ x = 1, y = 0, relative = true }), { repeating = true })
    hl.bind(mod .. " + SHIFT + H", hl.dsp.window.resize({ x = -1, y = 0, relative = true }), { repeating = true })
    hl.bind(mod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = -1, relative = true }), { repeating = true })
    hl.bind(mod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -1, relative = true }), { repeating = true })
    hl.bind(mod .. " + SHIFT + L", hl.dsp.window.resize({ x = -1, y = 0, relative = true }), { repeating = true })
    -- i3 resizes both opposite edges by 10px (20px total dimension change).
    hl.bind("left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- Gap mode from i3 (Alt+Shift+G, then +/-/0/d).
hl.bind(mod .. " + SHIFT + G", hl.dsp.submap("gaps"))
hl.define_submap("gaps", function()
    hl.bind("plus", function()
        inner_gap = inner_gap + 5
        hl.config({ general = { gaps_in = inner_gap } })
    end, { repeating = true })
    hl.bind("minus", function()
        inner_gap = math.max(0, inner_gap - 5)
        hl.config({ general = { gaps_in = inner_gap } })
    end, { repeating = true })
    hl.bind("0", function()
        inner_gap, outer_gap = 0, 0
        hl.config({ general = { gaps_in = inner_gap, gaps_out = outer_gap } })
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("D", function()
        inner_gap, outer_gap = 12, 0
        hl.config({ general = { gaps_in = inner_gap, gaps_out = outer_gap } })
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- TeamViewer/remote-session throughput mode retained from i3.
hl.bind(mod .. " + SHIFT + T", hl.dsp.submap("throughput"))
hl.define_submap("throughput", function()
    hl.bind(mod .. " + SHIFT + T", hl.dsp.submap("reset"))
    hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- Alt+mouse move/resize is the i3 floating-window gesture. The keyboard mouse
-- simulation mode was explicitly discarded during the migration review.
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Wayland screenshots and multimedia keys.
hl.bind("Print", hl.dsp.exec_cmd("~/.config/hypr/screenshot.sh"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/.config/hypr/brightness.sh +5"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/hypr/brightness.sh -5"), { locked = true, repeating = true })

-- Window rules carried over from i3.
hl.window_rule({ name = "pdfpc-borderless", match = { class = "^pdfpc$" }, border_size = 0, float = true })
hl.window_rule({ name = "pdfpc-title-borderless", match = { title = "^pdfpc$" }, border_size = 0, float = true })
hl.window_rule({ name = "thunar-tiled", match = { class = "^(Thunar|thunar)$" }, float = false })
hl.window_rule({ name = "tk-floating", match = { class = "^Tk$" }, float = true })
hl.window_rule({ name = "octave-floating", match = { class = "^(Octave-gui|octave-gui)$" }, float = true })
hl.window_rule({ name = "chrome-tiled", match = { class = "^(Google-chrome|google-chrome)$" }, float = false })
hl.window_rule({ name = "figure-floating", match = { title = "^Figure.*" }, float = true })
hl.window_rule({ name = "market-tiled", match = { title = "market" }, float = false })
hl.window_rule({ name = "scratchpad-window", match = { class = "^scratchpadurxvt$" }, workspace = "special:scratch", float = true })
hl.window_rule({ name = "float-pls", match = { title = "float_pls" }, float = true })
hl.window_rule({ name = "optic-flow-tiled", match = { title = "optic_flow" }, float = false })
hl.window_rule({
    name = "teams-notification-floating",
    match = {
        title = "^Microsoft Teams Notification$",
        class = "^(microsoft teams - preview|Microsoft Teams - Preview)$",
    },
    float = true,
})
