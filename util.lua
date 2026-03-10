local util = {}

function util.clamp(x, lo, hi)
  if x < lo then return lo end
  if x > hi then return hi end
  return x
end

function util.deepcopy(t)
  if type(t) ~= "table" then return t end
  local out = {}
  for k, v in pairs(t) do
    out[k] = util.deepcopy(v)
  end
  return out
end

function util.jsonEncode(value)
  local t = type(value)
  if t == "nil" then
    return "null"
  elseif t == "boolean" then
    return value and "true" or "false"
  elseif t == "number" then
    if value ~= value or value == math.huge or value == -math.huge then
      return "null"
    end
    return tostring(value)
  elseif t == "string" then
    return string.format("%q", value)
  elseif t == "table" then
    local isArray = true
    local n = 0
    for k, _ in pairs(value) do
      if type(k) ~= "number" then
        isArray = false
        break
      end
      if k > n then n = k end
    end

    if isArray then
      local parts = {}
      for i = 1, n do
        parts[#parts + 1] = util.jsonEncode(value[i])
      end
      return "[" .. table.concat(parts, ",") .. "]"
    else
      local parts = {}
      for k, v in pairs(value) do
        if type(k) == "string" then
          parts[#parts + 1] = util.jsonEncode(k) .. ":" .. util.jsonEncode(v)
        end
      end
      return "{" .. table.concat(parts, ",") .. "}"
    end
  end
  return "null"
end

local function jsonSkipWhitespace(s, i)
  while true do
    local c = s:sub(i, i)
    if c == "" then return i end
    if c ~= " " and c ~= "\n" and c ~= "\r" and c ~= "\t" then
      return i
    end
    i = i + 1
  end
end

local function jsonParseString(s, i)
  i = i + 1
  local out = {}
  while true do
    local c = s:sub(i, i)
    if c == "" then return nil, i end
    if c == '"' then
      return table.concat(out), i + 1
    end
    if c == "\\" then
      local esc = s:sub(i + 1, i + 1)
      if esc == '"' or esc == "\\" or esc == "/" then
        out[#out + 1] = esc
        i = i + 2
      elseif esc == "b" then out[#out + 1] = "\b"; i = i + 2
      elseif esc == "f" then out[#out + 1] = "\f"; i = i + 2
      elseif esc == "n" then out[#out + 1] = "\n"; i = i + 2
      elseif esc == "r" then out[#out + 1] = "\r"; i = i + 2
      elseif esc == "t" then out[#out + 1] = "\t"; i = i + 2
      else
        return nil, i
      end
    else
      out[#out + 1] = c
      i = i + 1
    end
  end
end

local function jsonParseNumber(s, i)
  local start = i
  local c = s:sub(i, i)
  if c == "-" then i = i + 1 end
  while s:sub(i, i):match("%d") do i = i + 1 end
  if s:sub(i, i) == "." then
    i = i + 1
    while s:sub(i, i):match("%d") do i = i + 1 end
  end
  local e = s:sub(i, i)
  if e == "e" or e == "E" then
    i = i + 1
    local sign = s:sub(i, i)
    if sign == "+" or sign == "-" then i = i + 1 end
    while s:sub(i, i):match("%d") do i = i + 1 end
  end
  local num = tonumber(s:sub(start, i - 1))
  return num, i
end

local jsonParseValue

local function jsonParseArray(s, i)
  i = i + 1
  local arr = {}
  i = jsonSkipWhitespace(s, i)
  if s:sub(i, i) == "]" then return arr, i + 1 end
  local idx = 1
  while true do
    local v
    v, i = jsonParseValue(s, i)
    if v == nil and s:sub(i, i) ~= "n" then return nil, i end
    arr[idx] = v
    idx = idx + 1
    i = jsonSkipWhitespace(s, i)
    local c = s:sub(i, i)
    if c == "," then
      i = jsonSkipWhitespace(s, i + 1)
    elseif c == "]" then
      return arr, i + 1
    else
      return nil, i
    end
  end
end

local function jsonParseObject(s, i)
  i = i + 1
  local obj = {}
  i = jsonSkipWhitespace(s, i)
  if s:sub(i, i) == "}" then return obj, i + 1 end
  while true do
    i = jsonSkipWhitespace(s, i)
    if s:sub(i, i) ~= '"' then return nil, i end
    local key
    key, i = jsonParseString(s, i)
    i = jsonSkipWhitespace(s, i)
    if s:sub(i, i) ~= ":" then return nil, i end
    i = jsonSkipWhitespace(s, i + 1)
    local val
    val, i = jsonParseValue(s, i)
    obj[key] = val
    i = jsonSkipWhitespace(s, i)
    local c = s:sub(i, i)
    if c == "," then
      i = jsonSkipWhitespace(s, i + 1)
    elseif c == "}" then
      return obj, i + 1
    else
      return nil, i
    end
  end
end

jsonParseValue = function(s, i)
  i = jsonSkipWhitespace(s, i)
  local c = s:sub(i, i)
  if c == "" then return nil, i end
  if c == '"' then return jsonParseString(s, i) end
  if c == "[" then return jsonParseArray(s, i) end
  if c == "{" then return jsonParseObject(s, i) end
  if c == "t" and s:sub(i, i + 3) == "true" then return true, i + 4 end
  if c == "f" and s:sub(i, i + 4) == "false" then return false, i + 5 end
  if c == "n" and s:sub(i, i + 3) == "null" then return nil, i + 4 end
  if c:match("[%-%d]") then return jsonParseNumber(s, i) end
  return nil, i
end

function util.jsonDecode(s)
  if type(s) ~= "string" then return nil end
  local v, i = jsonParseValue(s, 1)
  if v == nil then return nil end
  i = jsonSkipWhitespace(s, i)
  if i <= #s then
    return nil
  end
  return v
end

function util.nowIsoLike()
  local t = os.date("*t")
  return string.format(
    "%04d-%02d-%02d %02d:%02d:%02d",
    t.year, t.month, t.day, t.hour, t.min, t.sec
  )
end

return util

