function love.conf(t)
    t.version = "11.5"
    t.title = "Procedural snake"
    t.window.width = 1000
    t.window.height = 700
    t.window.borderless = false
    t.window.vsync = 0
    t.window.fullscreen = false

    --BEFORE BUILD: Turn console off
    t.console = true
end
