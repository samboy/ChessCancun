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

-- The CSS for the diagram
theCSS = [[
@import url(ChessCancunColor.css);
.chessDiagram8 { font-family: ChessCancunColor; font-size: 30px;
display: grid;
    grid-template-columns: repeat(8, 1fr);
    grid-template-rows: repeat(8, 1fr);
    width: 300px;
    height: 300px;
    border: 2px solid #333;
}

.chessDiagram8 div {
    text-align: center;
    padding-top: 1px; padding-bottom: -1px;
    background-color: #fff; /* Light square */
}

/* Alternating colors using nth-child */
.chessDiagram8 div:nth-child(-n+8):nth-child(even),
.chessDiagram8 div:nth-child(n+9):nth-child(-n+16):nth-child(odd),
.chessDiagram8 div:nth-child(n+17):nth-child(-n+24):nth-child(even),
.chessDiagram8 div:nth-child(n+25):nth-child(-n+32):nth-child(odd),
.chessDiagram8 div:nth-child(n+33):nth-child(-n+40):nth-child(even),
.chessDiagram8 div:nth-child(n+41):nth-child(-n+48):nth-child(odd),
.chessDiagram8 div:nth-child(n+49):nth-child(-n+56):nth-child(even),
.chessDiagram8 div:nth-child(n+57):nth-child(-n+64):nth-child(odd) {
    background-color: #ddd; /* Dark square */
}

.chessDiagram10x8 { font-family: ChessCancunColor; font-size: 30px;
display: grid;
    grid-template-columns: repeat(10, 1fr);
    grid-template-rows: repeat(8, 1fr);
    width: 375px;
    height: 300px;
    border: 2px solid #333;
}

.chessDiagram10x8 div {
    text-align: center;
    padding-top: 1px; padding-bottom: -1px;
    background-color: #fff; /* Light square */
}

/* Alternating colors using nth-child */
.chessDiagram10x8 div:nth-child(-n+10):nth-child(even),
.chessDiagram10x8 div:nth-child(n+11):nth-child(-n+20):nth-child(odd),
.chessDiagram10x8 div:nth-child(n+21):nth-child(-n+30):nth-child(even),
.chessDiagram10x8 div:nth-child(n+31):nth-child(-n+40):nth-child(odd),
.chessDiagram10x8 div:nth-child(n+41):nth-child(-n+50):nth-child(even),
.chessDiagram10x8 div:nth-child(n+51):nth-child(-n+60):nth-child(odd),
.chessDiagram10x8 div:nth-child(n+61):nth-child(-n+70):nth-child(even),
.chessDiagram10x8 div:nth-child(n+71):nth-child(-n+80):nth-child(odd) {
    background-color: #ddd; /* Dark square */
}
]]

function FENtoDiagram(FEN)
  local line = ""
  local out = "<div class=chessDiagram8>" -- Use 10x8 for Capablanca
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
      if FEN:sub(a,a) == "/" then break end
      width = width + 1
    end
  end
  number = 0
  inNumber = false

  -- We now know the width of the board, output the first row in 
  -- diagram notation (this is the notation the ChessCancun font uses)
  -- This is the top border of the Chess board
  for a=1,#FEN do
    local thisSquare = FEN:sub(a,a)
    if thisSquare:match("%d") and inNumber == false then
      number = tonumber(FEN:sub(a,a))
      inNumber = true
    elseif thisSquare:match("%d") then
      number = number * 10
      number = number + tonumber(FEN:sub(a,a))
    end
    if thisSquare:match("%D") or a==#FEN then 
      for b=1,number do
        out = out .. "<div></div> " -- Empty square
      end
      number = 0
      inNumber = false
    end  
    if thisSquare:match("%a") then 
      -- Chacellor/Marshal Rook + Knight piece is “M” in our mapping
      if thisSquare == 'C' then
        thisSquare = 'M'
      end
      if thisSquare == 'c' then
        thisSquare = 'm'
      end
      out = out .. "<div>" .. thisSquare .. "</div> "
    end
  end
  out = out .. "</div>"
  return out
end

FEN = arg[1]
if not FEN then 
  FEN="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
end

print(FENtoDiagram(FEN))
