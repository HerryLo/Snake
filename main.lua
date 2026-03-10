local config = require("config")
local Game = require("game")
local Scores = require("scores")

local state = "menu" -- menu | playing | paused | gameover | leaderboard
local g
local leaderboard = {}
local lastSavedScore = nil

local function setColor(c)
  love.graphics.setColor(c[1], c[2], c[3], c[4] or 1)
end

local function centerText(text, y, color, scale)
  scale = scale or 1
  if color then setColor(color) end
  local font = love.graphics.getFont()
  local w = font:getWidth(text) * scale
  local x = (love.graphics.getWidth() - w) / 2
  love.graphics.print(text, x, y, 0, scale, scale)
end

local function reloadLeaderboard()
  leaderboard = Scores.load()
end

local function startNewGame()
  g = Game.new()
  lastSavedScore = nil
  state = "playing"
end

local function saveScoreIfNeeded()
  if not g then return end
  if g.score <= 0 then return end
  if lastSavedScore == g.score then return end
  leaderboard = Scores.add(leaderboard, g.score, "PLAYER")
  Scores.save(leaderboard)
  lastSavedScore = g.score
end

function love.load()
  love.math.setRandomSeed(os.time())
  love.graphics.setBackgroundColor(config.colors.bg)
  reloadLeaderboard()
end

function love.update(dt)
  if state == "playing" then
    Game.update(g, dt)
    if not g.alive then
      saveScoreIfNeeded()
      state = "gameover"
    end
  end
end

local function drawHud()
  local lines = Game.getHudLines(g, state == "paused")
  setColor(config.colors.text)
  love.graphics.print(lines[1], 40, 18)
  setColor(config.colors.muted)
  love.graphics.print(lines[2], 170, 18)

  setColor(config.colors.muted)
  local hint = "WASD/Arrow: Move   Alt: Pause   Space: Restart   L: Leaderboard   Esc: Menu"
  love.graphics.print(hint, 40, 40)
end

local function drawLeaderboard(x, y, w)
  w = w or 420
  local h = 320
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local scale = math.min(sw / 1000, sh / 1000)
  local pad = math.max(10, math.floor(16 * scale + 0.5))
  local titleY = math.max(10, math.floor(14 * scale + 0.5))
  local firstRowY = math.max(36, math.floor(52 * scale + 0.5))
  local rowStep = math.max(16, math.floor(24 * scale + 0.5))

  setColor(config.colors.panel)
  love.graphics.rectangle("fill", x, y, w, h, 12, 12)
  setColor(config.colors.panelBorder)
  love.graphics.rectangle("line", x, y, w, h, 12, 12)

  setColor(config.colors.text)
  love.graphics.print("Leaderboard (Top 10)", x + pad, y + titleY)

  if #leaderboard == 0 then
    setColor(config.colors.muted)
    love.graphics.print("No scores yet. Play a round!", x + pad, y + firstRowY)
    return
  end

  local rowY = y + firstRowY
  for i, e in ipairs(leaderboard) do
    if i > config.maxLeaderboardEntries then break end
    setColor(config.colors.muted)
    love.graphics.print(string.format("%2d.", i), x + pad, rowY)
    setColor(config.colors.text)
    love.graphics.print(string.format("%-8s", e.name or "PLAYER"), x + pad + math.floor(40 * scale + 0.5), rowY)
    setColor(config.colors.text)
    love.graphics.print(string.format("%4d", tonumber(e.score) or 0), x + w - pad - math.floor(60 * scale + 0.5), rowY)
    setColor(config.colors.muted)
    love.graphics.print(e.ts or "", x + pad + math.floor(120 * scale + 0.5), rowY)
    rowY = rowY + rowStep
  end
end

local function drawLeaderboardCentered(w)
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local scale = math.min(sw / 1000, sh / 1000)
  w = w or math.floor(520 * scale + 0.5)
  local h = math.floor(320 * scale + 0.5)
  w = math.max(300, math.min(w, sw - 80))
  h = math.max(200, math.min(h, sh - 80))

  love.graphics.setColor(0, 0, 0, 0.35)
  love.graphics.rectangle("fill", 0, 0, sw, sh)

  local x = (sw - w) / 2
  local y = (sh - h) / 2 + math.floor(40 * scale + 0.5)
  drawLeaderboard(x, y, w)
end

function love.draw()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  if state == "playing" or state == "paused" or state == "gameover" then
    drawHud()
    Game.draw(g)

    if state == "paused" then
      centerText("PAUSED", math.floor(sh * 0.35), config.colors.text, 2)
      setColor(config.colors.muted)
      centerText("Alt: Resume   Space: Restart", math.floor(sh * 0.35) + 50, config.colors.muted, 1)
    elseif state == "gameover" then
      centerText("GAME OVER", math.floor(sh * 0.32), config.colors.danger, 2)
      setColor(config.colors.text)
      centerText(string.format("Score: %d", g.score), math.floor(sh * 0.32) + 50, config.colors.text, 1.2)
      setColor(config.colors.muted)
      centerText("Space: Restart   L: Leaderboard   Esc: Menu", math.floor(sh * 0.32) + 90, config.colors.muted, 1)
      drawLeaderboardCentered()
    end
  elseif state == "menu" then
    centerText("SNAKE", math.floor(sh * 0.18), config.colors.text, 2.5)
    setColor(config.colors.muted)
    centerText("Enter: Start    L: Leaderboard    Esc: Quit", math.floor(sh * 0.26), config.colors.muted, 1)
    setColor(config.colors.muted)
    centerText("WASD/Arrow: Move   Alt: Pause   Space: Restart", math.floor(sh * 0.31), config.colors.muted, 1)
    drawLeaderboardCentered()
  elseif state == "leaderboard" then
    centerText("LEADERBOARD", math.floor(sh * 0.16), config.colors.text, 2)
    setColor(config.colors.muted)
    centerText("Esc: Back to menu", math.floor(sh * 0.23), config.colors.muted, 1)
    drawLeaderboardCentered()
  end
end

local function onMoveKey(key)
  if state ~= "playing" then return end
  if key == "up" or key == "w" then Game.setDirection(g, "up")
  elseif key == "down" or key == "s" then Game.setDirection(g, "down")
  elseif key == "left" or key == "a" then Game.setDirection(g, "left")
  elseif key == "right" or key == "d" then Game.setDirection(g, "right")
  end
end

function love.keypressed(key)
  if key == "escape" then
    if state == "menu" then
      love.event.quit()
      return
    end
    state = "menu"
    return
  end

  if state == "menu" then
    if key == "return" or key == "kpenter" then
      startNewGame()
      return
    elseif key == "l" then
      reloadLeaderboard()
      state = "leaderboard"
      return
    end
  elseif state == "leaderboard" then
    if key == "l" then
      state = "menu"
      return
    end
  elseif state == "playing" then
    if key == "lalt" or key == "ralt" then
      state = "paused"
      return
    elseif key == "space" then
      startNewGame()
      return
    elseif key == "l" then
      reloadLeaderboard()
      state = "leaderboard"
      return
    end
  elseif state == "paused" then
    if key == "lalt" or key == "ralt" then
      state = "playing"
      return
    elseif key == "space" then
      startNewGame()
      return
    elseif key == "l" then
      reloadLeaderboard()
      state = "leaderboard"
      return
    end
  elseif state == "gameover" then
    if key == "space" then
      startNewGame()
      return
    elseif key == "l" then
      reloadLeaderboard()
      state = "leaderboard"
      return
    end
  end

  onMoveKey(key)
end

