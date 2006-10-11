# $Id: Global.cls,v 1.4 2003/12/30 17:01:27 dk Exp $
local $PImage => Handle;

package IPA::Global {
    PImage close_edges(PImage input,HV *profile);
    PImage fill_holes(PImage input,HV *profile);
    PImage area_filter(PImage input,HV *profile);
    SV* identify_contours(PImage input,HV *profile);
    SV* identify_scanlines(PImage input,HV *profile);
    PImage fft( PImage input, HV * profile); 
    PImage band_filter( PImage input, HV * profile);
    void hlines( PImage input, int x, int y, SV * points, double color);
    void bar( PImage input, int x1, int y1, int x2, int y2, double color);
}