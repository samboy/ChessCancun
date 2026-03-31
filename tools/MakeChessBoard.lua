#!/bin/sh
_rem=--[=[

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

function svgHeader(scale, xmax, ymax, rotate)
  local width = math.floor(xmax * scale + 1.0)
  local height = math.floor(ymax * scale + 1.0)
  if not rotate then
    return '<svg viewBox="0 0 ' .. tostring((xmax + 2) * scale)
           .. ' ' ..
           tostring((ymax + 2) * scale) ..
           '" width="' .. width .. '" height="' .. height .. '" '
           .. 'xmlns="http://www.w3.org/2000/svg">'
  end
  return '<svg viewBox="0 0 ' .. tostring((ymax + 2) * scale)
         .. ' ' ..
         tostring((xmax + 2) * scale) ..
         '" width="' .. width .. '" height="' .. height .. '" '
         .. 'xmlns="http://www.w3.org/2000/svg">'
end
function svgFooter(scale, xmax, ymax, rotate)
  return '</svg>'
end
function rect(scale, width, height, x, y, color)
  return '<rect width="' .. tostring(width * scale) .. '" ' ..
         ' height="' .. tostring(height * scale) .. '" ' ..
         ' x="' .. tostring(x * scale) .. '" ' ..
         ' y="' .. tostring(y * scale) .. '" ' ..
         ' fill="' .. tostring(color) .. '" />'
end

-- Get args (board size, etc.)
width = 8 
if #arg >= 1 then
  if arg[1]:match("h") or arg[1]:match("%-") or arg[1]:match("%?") then
    print("Usage: MakeChessBoard {width} {height} {squaresize} {boardersize}")
    print("{darkcolor} {lightcolor}")
    print("Colors are any valid SVG color, e.g. #ccc or #fff etc.")
    print("Output is SVG file on stdout")
    os.exit(0)
  end
  width = tonumber(arg[1])
  if not width then
    print("<!-- Warning width not set using 8 -->")
    width = 8
  end
end
height = 8
if #arg >= 2 then
  height = tonumber(arg[2])
  if not height then
    print("<!-- Warning height not set using 8 -->")
    height = 8
  end
end
square = 50
if #arg >= 3 then
  square = tonumber(arg[3])
  if not square then
    print("<!-- Warning square not set using 50 -->")
    square = 50
  end
end
border = 4
if #arg >= 4 then
  border = tonumber(arg[4])
  if not border then
    print("<!-- Warning border not set using 4 -->")
    border = 4
  end
end
dark = "#ccc"
if #arg >= 5 then
  dark = arg[5]
end
light = "#fff"
if #arg >= 6 then
  light = arg[6]
end
scale = 1
