#!/bin/sh

# Copy these files for Nanoemoji Use
# Lower case: Black 
# Upper case: White
# A: Archbishop (Bishop + Knight) 0x41/0x61
# B: Bishop 0x42/0x62
# K: King 0x4b/0x6b
# M: Marshal (Rook + Knight) 0x4d/0x6d
# N: kNight 0x4e/0x6e
# P: Pawn 0x50/0x70
# Q: Queen 0x51/0x71
# R: Rook 0x52/0x72
# We don’t bother with the hatch form we use in non-color Chess
# Cancun; it’s better to use CSS and <span> for that (also, no borders)

cp BlackArchbishop.svg emoji_u0061.svg
cp WhiteArchbishop.svg emoju_u0041.svg
cp BlackBishop.svg emoji_u0062.svg
cp WhiteBishop.svg emoji_u0042.svg
cp BlackKing.svg emoji_u006b.svg
cp WhiteKing.svg emoji_u004b.svg
cp BlackMarshal.svg emoji_u006d.svg
cp WhiteMarshal.svg emoji_u004d.svg
cp BlackKnight.svg emoji_u006e.svg
cp WhiteKnight.svg emoji_u004e.svg 
cp BlackPawn.svg emoji_0070.svg
cp WhitePawn.svg emoji_0050.svg
cp BlackQueen.svg emoji_0071.svg
cp WhiteQueen.svg emoji_0051.svg
cp BlackRook.svg emoji_0072.svg
cp WhiteRook.svg emoji_0052.svg
