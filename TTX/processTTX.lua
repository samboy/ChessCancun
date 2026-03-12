#!/bin/sh
_rem=--[=[
# This script processes a TTX file for a COLR font
LUNACY=""
if command -v lunacy64 >/dev/null 2>&1 ; then
  LUNACY=lunacy64
elif command -v lua5.1 >/dev/null 2>&1 ; then
  LUNACY=lua5.1
elif command -v lua-5.1 >/dev/null 2>&1 ; then
  LUNACY=lua-5.1
elif command -v lunacy >/dev/null 2>&1 ; then
  LUNACY=lunacy
elif command -v luajit >/dev/null 2>&1 ; then
  LUNACY=luajit # I assume luajit will remain frozen at Lua 5.1
fi
if [ -z "$LUNACY" ] ; then
  echo Please install Lunacy or Lua 5.1
  echo https://github.com/samboy/lunacy
  exit 1
fi

exec $LUNACY $0 "$@"

# ]=]1
-- This script is written in Lua 5.1

-- This script has been donated to the public domain in 2026 by Sam Trenholme
-- If, for some reason, a public domain declation is not acceptable, it
-- may be licensed under the following terms:

-- Copyright 2026 Sam Trenholme
-- Permission to use, copy, modify, and/or distribute this software for
-- any purpose with or without fee is hereby granted.
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
-- WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-- Utility functions --
-- Since Lunacy doesn't have split(), we make
-- it ourselves.  Like Perl’s split(), this can
-- split on regular expressions
-- Input is string, regex, output is an array with the string parts
function split(s, splitOn)
  if not splitOn then splitOn = "," end
  local place = true
  local out = {}
  local mark
  local last = 1
  while place do
    place, mark = string.find(s, splitOn, last, false)
    if place then
      table.insert(out,string.sub(s, last, place - 1))
      last = mark + 1
    end
  end
  table.insert(out,string.sub(s, last, -1))
  return out
end

-- We need to go through tables in sorted order sometimes
-- Like pairs() but sorted
-- This assumes all keys are of the same type
function sPairs(inputTable,sFunc)
  if not sFunc then
    sFunc = function(a, b)
      local ta = type(a)
      local tb = type(b)
      if(ta == tb)
        then return a < b
      end
      return ta < tb
    end
  end
  local keyList = {}
  local index = 1
  for k,_ in pairs(inputTable) do
    table.insert(keyList,k)
  end
  table.sort(keyList,sFunc)
  return function()
    rvalue = keyList[index]
    index = index + 1
    return rvalue, inputTable[rvalue]
  end
end

-- Show usage
function showUsage()
  print("Usage: processTTX.lua {filename} {action} {params}")
  print('action can be "dump", "movey", or "ymult"')
  print('"dump" shows information about the TTX font')
  print('"movey" moves all of the sub-glyphs of a given COLR glyph')
  print('up or down by the subsequent glyph and numeric argument; positive')
  print('numbers move up and negative numbers down')
  print('"ymult" makes all of the sub-glyphs of a given COLR glyph')
  print('taller or shorter')
  os.exit(0)
end

-- Pass 1: Get information about the font
filename="ChessCancunColor.ttx"

if #arg >= 1 then
  filename=arg[1]
end
if filename:match("%-") or filename:match("^h") or filename:match("%?") then
  showUsage()
end
action = nil
if #arg >= 2 then
  action = arg[2]
end
param = nil
if #arg >= 3 then
  param = tonumber(arg[3])
end
if action == nil then
  showUsage()
end

handle = io.open(filename,"rb")
if not handle then
  print("Cannot open " .. filename .. "\n")
  os.exit(1)
end

none = {} -- Empty table used as "none" key
hmtx = {}
thisGlyph = none
thisColorGlyph = none
colr = {}
glyph = {}

for line in handle:lines() do
  -- Store mtx (width and left-right alignment) data
  if line:match("%<mtx name") then
    local fields = {}
    local name = ""
    local width = ""
    local lsb = "" -- lsb is horizontal alignment of glyph
    fields = split(line,'"')
    if fields and #fields > 6 then
      name=fields[2]
      width=fields[4]
      lsb=fields[6]
      if not hmtx[name] then hmtx[name] = {} end
      hmtx[name]['width'] = width
      hmtx[name]['lsb'] = lsb
    end
  end

  -- Find out min/max x/y for each glyph
  if line:match("%<TTGlyph name") then
    local fields = {}
    local name = ""
    fields = split(line,'"')
    if fields and #fields > 2 then
      name=fields[2]
      thisGlyph = name
      if not glyph[thisGlyph] then
        glyph[thisGlyph] = {}
        glyph[thisGlyph]['minX'] = 999999
        glyph[thisGlyph]['minY'] = 999999
        glyph[thisGlyph]['maxX'] = -999999
        glyph[thisGlyph]['maxY'] = -999999
      end
    end
  end
  if line:match("%<pt x") then
    local fields = {}
    local x = 0
    local y = 0
    fields = split(line,'"')
    if fields and #fields > 4 then
      x = tonumber(fields[2])
      y = tonumber(fields[4])
      if x then
        if x < glyph[thisGlyph]['minX'] then
          glyph[thisGlyph]['minX'] = x
        end
        if x > glyph[thisGlyph]['maxX'] then
          glyph[thisGlyph]['maxX'] = x
        end
      end
      if y then
        if y < glyph[thisGlyph]['minY'] then
          glyph[thisGlyph]['minY'] = y
        end
        if y > glyph[thisGlyph]['maxY'] then
          glyph[thisGlyph]['maxY'] = y
        end
      end
    end
  end

  -- Note which glyphs are together in a COLR glyph
  if line:match("%<ColorGlyph name") then
    local fields = {}
    local name = ""
    fields = split(line,'"')
    if fields and #fields > 2 then
      thisColorGlyph = fields[2]
      if not colr[thisColorGlyph] then
        colr[thisColorGlyph] = {}
      end
    end
  end 
  if line:match("%<layer colorID") then
    local fields = {}
    local name = ""
    fields = split(line,'"')
    if fields and #fields > 4 then
      name = fields[4]
      colr[thisColorGlyph][name] = true
    end
  end

end

handle:close()

if action == "dump" then
  print("<!--")
  for char in sPairs(colr) do
    print("Glyph " .. char)
    for subGlyph in sPairs(colr[char]) do
      print("\t" .. subGlyph)
    end
  end
  print("END COLR INFO")

  for char in sPairs(glyph) do
    print("Glyph " .. char)
    for param,val in sPairs(glyph[char]) do
      print("\t",param,val)
    end
  end
  print("END GLYPH INFO")
  print("-->")

elseif action == "movey" then
  if #arg < 4 then
    print("FATAL: movey needs two arguments: glyph then move")
    showUsage()
  end
  local tomove = arg[3]
  local move = tonumber(arg[4])
  if not move then
    print("FATAL: move arg is not a number")
    showUsage()
  end
  if not colr[tomove] then
    print("FATAL: Cannot find glyph " .. tomove)
    print('Use "dump" to list all COLR glyphs')
    showUsage()
  end
  local handle = io.open(filename,"rb")
  if not handle then 
    print("FATAL: Cannot open file " .. filename)
    os.exit(1)
  end
  local doMove = false
  for line in handle:lines() do
    if line:match("%<TTGlyph name") then
      local fields = {}
      local name = ""
      fields = split(line,'"')
      if fields and #fields > 2 then
        name=fields[2]
        if colr[tomove][name] then
          doMove = true
        else
          doMove = false
        end
      end
      print(line)
    elseif line:match("%<%/TTGlyph%>") then
      doMove = false
      print(line)
    elseif line:match("%<pt x") and doMove then
      local fields = {}
      local y = 0
      fields = split(line,'"')
      if fields and #fields > 6 then
        y = tonumber(fields[4])
        y = y + move
        print(fields[1] .. '"' .. fields[2] .. '"' .. fields[3] .. '"' ..
              tostring(y) .. '"' .. fields[5] .. '"' .. fields[6] .. '"' ..
              fields[7])
      else
        print(line)
      end
    else
      print(line)
    end
  end -- END "movey"

elseif action == "ymult" then
  if #arg < 4 then
    print("FATAL: ymult needs two arguments: glyph then mult")
    showUsage()
  end
  local tomult = arg[3]
  local mult = tonumber(arg[4])
  if not mult then
    print("FATAL: mult arg is not a number")
    showUsage()
  end
  if not colr[tomult] then
    print("FATAL: Cannot find glyph " .. tomult)
    print('Use "dump" to list all COLR glyphs')
    showUsage()
  end
  local handle = io.open(filename,"rb")
  if not handle then 
    print("FATAL: Cannot open file " .. filename)
    os.exit(1)
  end
  local doMult = false
  local name = ""
  for line in handle:lines() do
    if line:match("%<TTGlyph name") then
      local fields = {}
      fields = split(line,'"')
      if fields and #fields > 2 then
        name=fields[2]
        if colr[tomult][name] then
          doMult = true
        else
          doMult = false
        end
      end
      print(line)
    elseif line:match("%<%/TTGlyph%>") then
      doMult = false
      print(line)
    elseif line:match("%<pt x") and doMult then
      local fields = {}
      local y = 0
      fields = split(line,'"')
      if fields and #fields > 6 and glyph[name] then
        local miny = glyph[name]['minY']
        y = tonumber(fields[4])
        y = y - miny
        y = y * mult
        y = y + miny
        y = math.floor(y + 0.5) -- Round to integer
        print(fields[1] .. '"' .. fields[2] .. '"' .. fields[3] .. '"' ..
              tostring(y) .. '"' .. fields[5] .. '"' .. fields[6] .. '"' ..
              fields[7])
      else
        print(line)
      end
    else
      print(line)
    end
  end -- END "ymult"

else 
  print("Unknown action " .. action)
  os.exit(1)
end
     
