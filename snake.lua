local snake = {}

local opposite = {
  up = "down",
  down = "up",
  left = "right",
  right = "left",
}

local dirVec = {
  up = { 0, -1 },
  down = { 0, 1 },
  left = { -1, 0 },
  right = { 1, 0 },
}

function snake.new(startX, startY)
  return {
    body = {
      { x = startX, y = startY },
      { x = startX - 1, y = startY },
      { x = startX - 2, y = startY },
    },
    dir = "right",
    nextDir = "right",
    grow = 0,
  }
end

function snake.setDirection(s, dir)
  if dir ~= "up" and dir ~= "down" and dir ~= "left" and dir ~= "right" then
    return
  end
  if opposite[s.dir] == dir then
    return
  end
  s.nextDir = dir
end

function snake.head(s)
  return s.body[1]
end

function snake.occupies(s, x, y, fromIndex)
  local start = fromIndex or 1
  for i = start, #s.body do
    local seg = s.body[i]
    if seg.x == x and seg.y == y then
      return true
    end
  end
  return false
end

function snake.step(s)
  s.dir = s.nextDir
  local v = dirVec[s.dir]
  local h = s.body[1]
  local nx, ny = h.x + v[1], h.y + v[2]
  table.insert(s.body, 1, { x = nx, y = ny })

  if s.grow > 0 then
    s.grow = s.grow - 1
  else
    table.remove(s.body)
  end

  return nx, ny
end

function snake.addGrowth(s, amount)
  s.grow = s.grow + (tonumber(amount) or 1)
end

return snake

