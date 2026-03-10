-- leaderboard.lua
local Leaderboard = {}
Leaderboard.__index = Leaderboard

function Leaderboard:new(maxEntries)
    local lb = {
        entries = {},
        maxEntries = maxEntries or 10,
        filename = "snake_leaderboard.txt",
        playerName = ""
    }
    setmetatable(lb, Leaderboard)
    lb:load()
    return lb
end

-- 从文件加载排行榜
function Leaderboard:load()
    self.entries = {}
    if love.filesystem.getInfo(self.filename) then
        local content = love.filesystem.read(self.filename)
        if content and content ~= "" then
            -- 按行解析文件内容
            for line in content:gmatch("[^\r\n]+") do
                -- 格式: 名称,分数,日期
                local name, score, date = line:match("([^,]+),([^,]+),([^,]+)")
                if name and score then
                    table.insert(self.entries, {
                        name = name,
                        score = tonumber(score),
                        date = date or os.date("%Y-%m-%d")
                    })
                end
            end
            -- 按分数排序（从高到低）
            self:sort()
            -- 只保留前maxEntries名
            while #self.entries > self.maxEntries do
                table.remove(self.entries)
            end
        end
    end
end

-- 保存排行榜到文件
function Leaderboard:save()
    -- 先排序，确保保存的是最新的顺序
    self:sort()
    
    -- 只保存前maxEntries名
    local lines = {}
    local count = math.min(#self.entries, self.maxEntries)
    for i = 1, count do
        local entry = self.entries[i]
        table.insert(lines, string.format("%s,%d,%s", 
            entry.name, entry.score, entry.date))
    end
    
    -- 写入文件
    local content = table.concat(lines, "\n")
    love.filesystem.write(self.filename, content)
    
    -- 调试信息
    print("Saved " .. count .. " entries to leaderboard file")
end

-- 添加新记录
function Leaderboard:addEntry(name, score)
    -- 创建新条目
    local entry = {
        name = name,
        score = score,
        date = os.date("%Y-%m-%d")
    }
    
    -- 添加到列表
    table.insert(self.entries, entry)
    
    -- 重新排序
    self:sort()
    
    -- 只保留前maxEntries名
    while #self.entries > self.maxEntries do
        table.remove(self.entries)
    end
    
    -- 保存到文件
    self:save()
    
    -- 调试信息
    print("Added entry: " .. name .. " with score " .. score)
    print("Total entries after adding: " .. #self.entries)
end

-- 按分数排序（降序）
function Leaderboard:sort()
    table.sort(self.entries, function(a, b)
        return a.score > b.score
    end)
end

-- 检查分数是否能进入排行榜
function Leaderboard:isHighScore(score)
    -- 如果少于最大条目数，直接进入
    if #self.entries < self.maxEntries then
        return true
    end
    -- 如果有条目，检查是否大于等于最低分
    if #self.entries > 0 then
        return score > self.entries[#self.entries].score
    end
    return true
end

-- 获取排行榜条目（已经是排序后的前maxEntries名）
function Leaderboard:getEntries()
    return self.entries
end

-- 清除所有记录
function Leaderboard:clear()
    self.entries = {}
    self:save()
    print("Leaderboard cleared")
end

-- 设置当前玩家名称
function Leaderboard:setPlayerName(name)
    self.playerName = name
end

-- 获取当前玩家名称
function Leaderboard:getPlayerName()
    return self.playerName
end

-- 获取排行榜文件路径（调试用）
function Leaderboard:getFilePath()
    return love.filesystem.getSaveDirectory() .. "/" .. self.filename
end

return Leaderboard