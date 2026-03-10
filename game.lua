local config = require("config")
local Snake = require("snake")

local game = {}

local function randomEmptyCell(snakeObj)
  local empty = {}
  for y = 1, config.rows do
    for x = 1, config.cols do
      if not Snake.occupies(snakeObj, x, y) then
        empty[#empty + 1] = { x = x, y = y }
      end
    end
  end
  if #empty == 0 then return nil end
  return empty[love.math.random(1, #empty)]
end

function game.new()
  local startX = math.floor(config.cols / 2)
  local startY = math.floor(config.rows / 2)
  local g = {
    snake = Snake.new(startX, startY),
    food = { x = startX + 6, y = startY },
    score = 0,
    moveInterval = config.baseMoveInterval,
    timer = 0,
    alive = true,
  }
  local f = randomEmptyCell(g.snake)
  if f then g.food = f end
  return g
end

function game.reset(g)
  local fresh = game.new()
  for k, v in pairs(fresh) do
    g[k] = v
  end
end

function game.setDirection(g, dir)
  Snake.setDirection(g.snake, dir)
end

function game.update(g, dt)
  if not g.alive then return end
  g.timer = g.timer + dt
  while g.timer >= g.moveInterval do
    g.timer = g.timer - g.moveInterval

    local nx, ny = Snake.step(g.snake)

    if nx < 1 or nx > config.cols or ny < 1 or ny > config.rows then
      g.alive = false
      return
    end
    if Snake.occupies(g.snake, nx, ny, 2) then
      g.alive = false
      return
    end

    if nx == g.food.x and ny == g.food.y then
      g.score = g.score + 1
      Snake.addGrowth(g.snake, 1)

      if g.score % config.speedupEvery == 0 then
        g.moveInterval = math.max(config.minMoveInterval, g.moveInterval * config.speedupFactor)
      end

      local f = randomEmptyCell(g.snake)
      if f then
        g.food = f
      else
        g.alive = false
        return
      end
    end
  end
end

function game.draw(g)
  local ox, oy = config.boardOffsetX, config.boardOffsetY
  local cs = config.cellSize

  love.graphics.setColor(config.colors.panel)
  love.graphics.rectangle("fill", ox - 10, oy - 10, config.cols * cs + 20, config.rows * cs + 20, 12, 12)

  love.graphics.setColor(config.colors.panelBorder)
  love.graphics.rectangle("line", ox - 10, oy - 10, config.cols * cs + 20, config.rows * cs + 20, 12, 12)

  love.graphics.setColor(config.colors.gridLine)
  for x = 0, config.cols do
    local px = ox + x * cs
    love.graphics.line(px, oy, px, oy + config.rows * cs)
  end
  for y = 0, config.rows do
    local py = oy + y * cs
    love.graphics.line(ox, py, ox + config.cols * cs, py)
  end

  do
    local fx = ox + (g.food.x - 1) * cs
    local fy = oy + (g.food.y - 1) * cs
    local cx = fx + cs / 2
    local cy = fy + cs / 2
    local r = cs * 0.42

    love.graphics.setColor(config.colors.foodGlow)
    love.graphics.circle("fill", cx, cy, r + 3)

    love.graphics.setColor(config.colors.appleOutline)
    love.graphics.circle("fill", cx, cy + 1, r + 1.6)

    love.graphics.setColor(config.colors.appleDark)
    love.graphics.circle("fill", cx + r * 0.10, cy + 1 + r * 0.12, r * 0.98)

    love.graphics.setColor(config.colors.food)
    love.graphics.circle("fill", cx - r * 0.06, cy + 1 - r * 0.04, r * 0.90)

    love.graphics.setColor(config.colors.panel)
    love.graphics.circle("fill", cx, fy + cs * 0.18, r * 0.32)

    love.graphics.setColor(config.colors.appleSpecular)
    love.graphics.circle("fill", cx - r * 0.25, cy - r * 0.22, r * 0.26)
    love.graphics.setColor(1, 1, 1, 0.10)
    love.graphics.circle("fill", cx - r * 0.10, cy - r * 0.02, r * 0.14)

    love.graphics.setColor(config.colors.appleStem)
    local stemW = math.max(2, cs * 0.12)
    local stemH = math.max(3, cs * 0.26)
    love.graphics.push()
    love.graphics.translate(cx, fy + cs * 0.22)
    love.graphics.rotate(-0.35)
    love.graphics.rectangle("fill", -stemW / 2, -stemH, stemW, stemH, 2, 2)
    love.graphics.pop()

    love.graphics.setColor(config.colors.appleLeafShadow)
    love.graphics.ellipse("fill", cx + cs * 0.22, fy + cs * 0.13, cs * 0.20, cs * 0.11)
    love.graphics.setColor(config.colors.appleLeafOutline)
    love.graphics.ellipse("fill", cx + cs * 0.22, fy + cs * 0.10, cs * 0.21, cs * 0.12)
    love.graphics.setColor(config.colors.appleLeaf)
    love.graphics.ellipse("fill", cx + cs * 0.22, fy + cs * 0.10, cs * 0.19, cs * 0.10)
    love.graphics.setColor(1, 1, 1, 0.14)
    love.graphics.line(cx + cs * 0.12, fy + cs * 0.10, cx + cs * 0.30, fy + cs * 0.09)
  end

  for i, seg in ipairs(g.snake.body) do
    if i == 1 then
      local x = ox + (seg.x - 1) * cs
      local y = oy + (seg.y - 1) * cs

      love.graphics.setColor(config.colors.snakeHeadOutline)
      love.graphics.rectangle("fill", x - 2, y - 2, cs + 4, cs + 4, 10, 10)

      love.graphics.setColor(config.colors.snakeHead)
      love.graphics.rectangle("fill", x, y, cs, cs, 10, 10)

      love.graphics.setColor(config.colors.snakeHeadHighlight)
      love.graphics.rectangle("fill", x + 2, y + 2, cs - 4, math.floor(cs * 0.45), 10, 10)

      local dir = g.snake.dir or "right"
      local ex1, ey1, ex2, ey2
      if dir == "up" then
        ex1, ey1 = x + cs * 0.35, y + cs * 0.30
        ex2, ey2 = x + cs * 0.65, y + cs * 0.30
      elseif dir == "down" then
        ex1, ey1 = x + cs * 0.35, y + cs * 0.70
        ex2, ey2 = x + cs * 0.65, y + cs * 0.70
      elseif dir == "left" then
        ex1, ey1 = x + cs * 0.30, y + cs * 0.35
        ex2, ey2 = x + cs * 0.30, y + cs * 0.65
      else
        ex1, ey1 = x + cs * 0.70, y + cs * 0.35
        ex2, ey2 = x + cs * 0.70, y + cs * 0.65
      end
      local rW = math.max(2, math.floor(cs * 0.14))
      local rP = math.max(1, math.floor(cs * 0.07))
      love.graphics.setColor(config.colors.eyeWhite)
      love.graphics.circle("fill", ex1, ey1, rW)
      love.graphics.circle("fill", ex2, ey2, rW)
      love.graphics.setColor(config.colors.eyePupil)
      love.graphics.circle("fill", ex1, ey1, rP)
      love.graphics.circle("fill", ex2, ey2, rP)
    else
      love.graphics.setColor(config.colors.snakeBody)
      love.graphics.rectangle("fill", ox + (seg.x - 1) * cs, oy + (seg.y - 1) * cs, cs, cs, 8, 8)
    end
  end
end

function game.getHudLines(g, isPaused)
  local speed = math.floor((config.baseMoveInterval / g.moveInterval) * 100 + 0.5) / 100
  local lines = {
    string.format("Score: %d", g.score),
    string.format("Speed: x%.2f", speed),
  }
  if isPaused then
    lines[#lines + 1] = "Paused"
  end
  return lines
end

return game

