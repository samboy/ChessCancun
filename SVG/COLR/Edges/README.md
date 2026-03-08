These are the edges that go around the chessboard.  In addition to the 
corner squares (`cNW`, `cNE`, `cSW`, and `cSE`) and the edge squares (`N`,
`S`, `E`, `W`) for square boards, we also have a square shape for a spot
not in play inside a chessboard (`NSEW`) and multisided edges (`NW`, with 
edges on the left and top, as well as the corresponding `SW`, `SE`, and `NE`
multi-edge shapes).  These extra shapes allows support for variants with 
exotic shaped boards, such as the Gustav board or even Crazy 38s.
