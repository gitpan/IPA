# $Id: Geometry.cls,v 1.2 2000/02/17 13:02:45 tobez Exp $

local $PImage => Handle;

package IPA::Geometry {
    PImage mirror( PImage input, HV *profile);
    PImage shift_rotate( PImage img, HV *profile);
}

# profile for mirror:
#  type => how, where `how' is 1 for vertical and 2 for horizontal
# profile for shift_rotate:
#  where => how, where `how' is 1 for vertical and 2 for horizontal
#  size => integer - for how many pixels/scan lines
