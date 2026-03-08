#!/bin/sh

# This project has been paused: nanoemoji needs to be hacked to always
# make 2048x2048 characters in the font, to not move down the “top” box
# drawing characters, so that
# - The Box drawing characters work to make an edge for the board
# - The Black squares are flush against the White squares on the
#   checkerboard
# Until we either get a F/OSS font editor with COLR0 support, or I
# figure out how to hack nanoemoji to make fixed width glyphs, I am
# pausing this project

# Copy these files for Nanoemoji Use
# This is a superset of the “hatch form” character set ChessCancun uses
# Cancun; it’s better to use CSS and <span> for that (also, no borders)

cp BlackArchbishop.svg emoji_u0073.svg # s
cp WhiteArchbishop.svg emoji_u0061.svg # a
cp BlackBishop.svg emoji_u0076.svg # v
cp WhiteBishop.svg emoji_u0062.svg # b
cp BlackKing.svg emoji_u006c.svg # l
cp WhiteKing.svg emoji_u006b.svg # k
cp BlackMarshal.svg emoji_u0066.svg # f
cp WhiteMarshal.svg emoji_u0064.svg # d
cp BlackKnight.svg emoji_u006d.svg # m
cp WhiteKnight.svg emoji_u006e.svg # n
cp BlackPawn.svg emoji_u006f.svg # o
cp WhitePawn.svg emoji_u0070.svg # p
cp BlackQueen.svg emoji_u0077.svg # w
cp WhiteQueen.svg emoji_u0071.svg # q
cp BlackRook.svg emoji_u0074.svg # t
cp WhiteRook.svg emoji_u0072.svg # r
# the inverted pieces are next to each other on QWERTY
cp WhiteBishopInverted.svg emoji_u007a.svg # z
cp BlackBishopInverted.svg emoji_u0078.svg # x
cp WhiteKnightInverted.svg emoji_u0067.svg # g
cp BlackKnightInverted.svg emoji_u0068.svg # h
# Pieces on dark squares are upper-case of above
cp OnDarkSquare/BlackArchbishop.svg emoji_u0053.svg # S
cp OnDarkSquare/WhiteArchbishop.svg emoji_u0041.svg # A
cp OnDarkSquare/BlackBishop.svg emoji_u0056.svg # V
cp OnDarkSquare/WhiteBishop.svg emoji_u0042.svg # B
cp OnDarkSquare/BlackKing.svg emoji_u004c.svg # L
cp OnDarkSquare/WhiteKing.svg emoji_u004b.svg # K
cp OnDarkSquare/BlackMarshal.svg emoji_u0046.svg # F
cp OnDarkSquare/WhiteMarshal.svg emoji_u0044.svg # D
cp OnDarkSquare/BlackKnight.svg emoji_u004d.svg # M
cp OnDarkSquare/WhiteKnight.svg emoji_u004e.svg # N
cp OnDarkSquare/BlackPawn.svg emoji_u004f.svg # O
cp OnDarkSquare/WhitePawn.svg emoji_u0050.svg # P
cp OnDarkSquare/BlackQueen.svg emoji_u0057.svg # W
cp OnDarkSquare/WhiteQueen.svg emoji_u0051.svg # Q
cp OnDarkSquare/BlackRook.svg emoji_u0054.svg # T
cp OnDarkSquare/WhiteRook.svg emoji_u0052.svg # R
cp OnDarkSquare/WhiteBishopInverted.svg emoji_u007a.svg # Z
cp OnDarkSquare/BlackBishopInverted.svg emoji_u0078.svg # X
cp OnDarkSquare/WhiteKnightInverted.svg emoji_u0067.svg # G
cp OnDarkSquare/BlackKnightInverted.svg emoji_u0068.svg # H
# Dark square
cp OnDarkSquare/Square.svg emoji_u002b.svg # +
# Light square
# It looks like this causes nanoemoji to fail with a useless error message
#cp LightSquare.svg emoji_u0020.svg # {space}
# Edges and corners
cp Edges/cSE.svg emoji_u0021.svg # !
cp Edges/S.svg emoji_u0022.svg # "
cp Edges/cSW.svg emoji_u0023.svg # #
cp Edges/E.svg emoji_u0024.svg # $
cp Edges/W.svg emoji_u0025.svg # %
cp Edges/cNE.svg emoji_u002f.svg # /
cp Edges/N.svg emoji_u0028.svg # (
cp Edges/cNW.svg emoji_u0029.svg # )
# Expanded edges/corners (not in ChessCancun)
cp Edges/NW.svg emoji_u005b.svg # [
cp Edges/NE.svg emoji_u005d.svg # ]
cp Edges/SW.svg emoji_u007b.svg # {
cp Edges/SE.svg emoji_u007d.svg # }
cp Edges/NSEW.svg emoji_u002a.svg # *
# This only runs in Ubuntu
nanoemoji --family ChessCancunX --color_format glyf_colr_0 emoji_*
