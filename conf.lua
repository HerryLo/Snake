-- conf.lua
function love.conf(t)
    t.window.title = "Snake Game"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.console = false  -- 开启控制台以便调试
end