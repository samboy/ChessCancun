This is a color font which uses COLR0 font support which allows the font
to have proper white background in the figures, allowing us to have a 
different background color, allowing us to use CSS to specify the
background color.

The only colors used by the font are white and black.

The font was made in the `SVG/WhiteBG` directory using the following
commands:

```
sh make.nanoemoji.sh
#nanoemoji --family ChessCancunColor --color_format glyf_colr_0 emoji_*
```

(This had to be done in Ubuntu 24.04 LTS because it’s impossible to
 install nanoemoji in Cygwin.  Sigh.)

The font has subsequently been edited by coverting the font to XML
using TTX, then editing the TTX font by hand.  In particular, it
now will show the figures on systems without COLR support (albeit
without the white “filling” so the figures look good on non-white
backgrounds), and the figures can be more tightly fit in a CSS grid.

The mapping is this, where lower case is Black and upper case is White
(as per the FEN specification):

* `a`: Archbishop (Bishop + Knight)
* `b`: Bishop
* `k`: King
* `m`: Marshal (Rook + Knight)
* `n`: kNight
* `p`: Pawn
* `q`: Queen
* `r`: Rook

This font only works in environments where a font with COLR0 support
works.  Fontforge doesn’t support this format, nor does the Windows11
operating system; this is a font for web browsers, to allow me to
fit 250k worth of SVG icons in a tiny 15k WOFF2 file.  Nicely enough,
LibreOffice *does* support this color font, so that word processor can
used when one wants to make printed Chess diagrams.

More discussion:

https://archive.ph/20260304061031/https://typedrawers.com/discussion/comment/67849

