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
  echo Either the version included with this blog -or- the version at
  echo https://github.com/samboy/lunacy
  echo To compile and install the version of Lunacy with the blog:
  echo
  echo     tar xvJf lunacy-2022-12-06.tar.xz
  echo     cd lunacy-2022-12-06/
  echo     make
  echo     sudo cp lunacy /usr/local/bin/
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

function FENtoDiagram(FEN)
  -- White -> Black mapping
  local map={}
  map.p = "o"
  map.n = "m"
  map.b = "v"
  map.r = "t"
  map.q = "w"
  map.k = "l"
  map.a = "s"
  map.d = "f"
  map.c = "f"
  map.m = "f"

  local line = ""
  local out = ""
  local color = 0 -- Upper left square is white
  local width = 0
  local number = 0
  local inNumber = false
  for a=1,#FEN do
    if FEN:sub(a,a):match("%d") and inNumber == false then
      number = tonumber(FEN:sub(a,a))
      inNumber = true
    elseif FEN:sub(a,a):match("%d") then
      number = number * 10
      number = number + tonumber(FEN:sub(a,a))
    else
      inNumber = false
      width = width + number
      number = 0
    end
    if FEN:sub(a,a) == "/" then break end
    width = width + 1
    a = a + 1
  end
  number = 0

  -- We now know the width of the board, output the first row in 
  -- diagram notation (this is the notation the ChessCancun font uses)
  -- This is the top border of the Chess board
  out = "!"
  for a=1,width do
    out = out .. '"'
  end
  out = out .. '#'
  return out -- DEBUG
end

FEN = arg[1]
if not FEN then 
  FEN="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
end

print(FENtoDiagram(FEN))
