# $Id: Point.cls,v 1.2 2000/02/18 10:52:07 voland Exp $
local $PImage => Handle;

package IPA::Point {
    PImage combine(HV *profile);
    PImage threshold(PImage input,HV *profile);
    PImage gamma(PImage input,HV *profile);
    PImage remap(PImage input,HV *profile);
    PImage subtract(PImage input1,PImage input2,HV *profile);
    PImage mask( PImage msk, HV *profile);
    PImage average( SV *list);
}

