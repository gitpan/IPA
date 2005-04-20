# $Id: Misc.cls,v 1.4 2003/02/20 13:30:54 dk Exp $
local $PImage => Handle;
local @Histogram int[ 256];

package IPA::Misc {
    SV * split_channels( PImage input, char * mode = "rgb");
    PImage combine_channels( SV * input, char * mode = "rgb");
    Histogram * histogram( PImage input);
}

