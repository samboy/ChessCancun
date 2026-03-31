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

function svgHeader(scale, xmax, ymax)
  local width = math.floor(xmax * scale + 1.0)
  local height = math.floor(ymax * scale + 1.0)
  return '<svg viewBox="0 0 ' .. tostring((xmax + 2) * scale)
           .. ' ' ..
           tostring((ymax + 2) * scale) ..
           '" width="' .. width .. '" height="' .. height .. '" '
           .. 'xmlns="http://www.w3.org/2000/svg">'
end
function svgFooter(scale, xmax, ymax)
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
border = 2
if #arg >= 4 then
  border = tonumber(arg[4])
  if not border then
    print("<!-- Warning border not set using 2 -->")
    border = 2
  end
end
dark = "#ccc"
if #arg >= 5 then
  dark = arg[5]
end
bordercolor = dark
light = "#fff"
if #arg >= 6 then
  light = arg[6]
end
scale = 1
xmax = 2 * border + square * width
ymax = 2 * border + square * height
-- Draw the board
print(svgHeader(scale,xmax,ymax))
-- Boarder
print(rect(scale, border, ymax-border, 0, 0, bordercolor)) -- Left
print(rect(scale, xmax-border, border, 0, ymax-border, bordercolor)) -- Right
print(rect(scale, xmax-border, border, border, 0, bordercolor)) -- Top
print(rect(scale, border, ymax-border, xmax-border, border, bordercolor)) 
-- Squares
for y=1,height do
  for x=1,width do
    local fill = dark
    if(y % 2 == 1) then
      if(x % 2 == 1) then
        fill = light
      end
    elseif(y % 2 == 0) then
      if(x % 2 == 0) then
        fill = light
      end
    end
    print(rect(scale,square,square,border + square * (x-1),
               border + square * (y-1),fill))
  end
end
print(svgFooter(scale,xmax,ymax))

