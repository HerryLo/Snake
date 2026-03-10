local config = require("config")
local util = require("util")

local scores = {}

local function normalizeEntries(raw)
  if type(raw) ~= "table" then return {} end
  local out = {}
  for _, e in ipairs(raw) do
    if type(e) == "table" then
      local s = tonumber(e.score) or 0
      local ts = type(e.ts) == "string" and e.ts or ""
      local name = type(e.name) == "string" and e.name or "PLAYER"
      out[#out + 1] = { score = s, ts = ts, name = name }
    end
  end
  table.sort(out, function(a, b)
    if a.score ~= b.score then return a.score > b.score end
    return (a.ts or "") > (b.ts or "")
  end)
  while #out > config.maxLeaderboardEntries do
    table.remove(out)
  end
  return out
end

local function parseScoresTxt(contents)
  if type(contents) ~= "string" or contents == "" then return {} end
  local raw = {}
  for line in contents:gmatch("[^\r\n]+") do
    local scoreStr, name, ts = line:match("^%s*(%d+)%s*\t([^\t]*)\t(.*)%s*$")
    if not scoreStr then
      scoreStr, ts = line:match("^%s*(%d+)%s*\t(.*)%s*$")
    end
    if not scoreStr then
      scoreStr = line:match("^%s*(%d+)%s*$")
    end
    local scoreNum = tonumber(scoreStr)
    if scoreNum and scoreNum > 0 then
      raw[#raw + 1] = {
        score = scoreNum,
        name = (type(name) == "string" and name ~= "") and name or "PLAYER",
        ts = type(ts) == "string" and ts or "",
      }
    end
  end
  return raw
end

local function formatScoresTxt(entries)
  local lines = {}
  for _, e in ipairs(entries) do
    local scoreNum = tonumber(e.score) or 0
    local name = (type(e.name) == "string" and e.name ~= "") and e.name or "PLAYER"
    local ts = type(e.ts) == "string" and e.ts or ""
    lines[#lines + 1] = string.format("%d\t%s\t%s", scoreNum, name, ts)
  end
  return table.concat(lines, "\n")
end

function scores.load()
  if not love.filesystem.getInfo(config.scoresFile) then
    return {}
  end
  local contents = love.filesystem.read(config.scoresFile)
  return normalizeEntries(parseScoresTxt(contents))
end

function scores.save(entries)
  local ok = love.filesystem.write(config.scoresFile, formatScoresTxt(entries))
  return ok
end

function scores.add(entries, scoreValue, playerName)
  local s = tonumber(scoreValue) or 0
  if s <= 0 then return normalizeEntries(entries) end
  local name = (type(playerName) == "string" and playerName ~= "") and playerName or "PLAYER"
  entries[#entries + 1] = { score = s, ts = util.nowIsoLike(), name = name }
  return normalizeEntries(entries)
end

return scores

