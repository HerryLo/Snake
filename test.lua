function love.load()
    print("测试模式 - 按P键查看是否响应")
end

function love.keypressed(key)
    print("按下的键: " .. tostring(key))
    
    if key == "p" then
        print("✓ 检测到小写p键")
    elseif key == "P" then
        print("✓ 检测到大写P键")
    end
    
    -- 显示所有按键信息
    print("键名: " .. key .. ", 键值: " .. tostring(key))
end

function love.draw()
    love.graphics.print("按P键测试 - 查看控制台输出", 100, 100)
end