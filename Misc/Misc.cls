# $Id: Misc.cls,v 1.3 2000/02/25 09:51:13 voland Exp $
local $PImage => Handle;
local @Histogram int[ 256];

package IPA::Misc {
    SV * split_channels( PImage input, char * mode = "rgb");
    Histogram * histogram( PImage input);
}

