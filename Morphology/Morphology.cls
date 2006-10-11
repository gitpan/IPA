# $Id: Morphology.cls,v 1.1.1.1 2000/01/13 16:46:57 voland Exp $
local $PImage => Handle;

package IPA::Morphology {
    PImage BWTransform(PImage img,HV *profile);
    PImage dilate( PImage IMi, HV *profile);
    PImage erode( PImage IMi, HV *profile);
#    import PImage opening( PImage IMi, HV *profile);  # see Morphology.pm
#    import PImage closing( PImage IMi, HV *profile);  # see Morphology.pm
    PImage algebraic_difference( PImage i1, PImage i2, HV *profile);
    PImage watershed( PImage IMi, HV *profile);
    PImage reconstruct( PImage I, PImage J, HV *profile);
    PImage thinning( PImage inp, HV *profile);
}
