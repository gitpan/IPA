# $Id: Local.cls,v 1.1.1.1 2000/01/13 16:46:57 voland Exp $
local $PImage => Handle;

package IPA::Local {
   PImage crispening(PImage input);
   PImage sobel(PImage input,HV *profile);
   PImage GEF(PImage input,HV *profile);
   PImage SDEF(PImage input,HV *profile);
   PImage deriche(PImage input, HV *profile);
   PImage filter3x3(PImage input,HV *profile);
   PImage median(PImage input,HV *profile);
   PImage unionFind(PImage input,HV *profile);
}

