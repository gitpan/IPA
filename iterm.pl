# $Id: iterm.pl,v 1.2 2002/06/25 16:01:39 dk Exp $

use strict;
use Prima qw(Application MsgBox ComboBox ImageViewer ImageDialog);
$::application-> name( 'ITerm');
$::application-> autoClose(0);
my $w;
my $HOME = defined( $ENV{HOME}) ? $ENV{HOME} : '.';
my $fdo;
my $fds;
my $vec = '';

use IPA::Global qw(/./);
use IPA::Local qw(/./);
use IPA::Geometry qw(/./);
use IPA::Misc qw(/./);
use IPA::Point qw(/./);
use IPA::Morphology qw(/./);


use vars qw($i $j @i @windows);

$i = Prima::Image-> create;
$j = Prima::Image-> create;

package main;

# user routines

sub new
{
   eval "\$$_[0] = Prima::Image-> create();";
}

sub show
{
   my $img = shift;
   $img = $i unless defined $img;
   show_error('Nothing to show'), return unless defined $img;
   $w-> Image-> image( $img);
}

sub clearhistory
{
   $w-> Input-> List-> items([]);
}

sub show_error
{
   $w-> Status-> text( $_[0]);
}

sub load
{
   my $x = Prima::Image-> load( @_);
   if ( $x) {
      $i = $x;
   } else {
      show_error( "error loading: $@");
   }
}

sub save
{
   my $img = shift;
   $img = $i unless defined $img;
   show_error('Nothing to save'), return unless defined $img;
   $img-> save( @_);
   show_error("$@") if $@; 
}


sub quit
{
   $::application-> close;
}

sub zoom
{
   $w-> Image-> zoom( $_[0]);
}

sub window
{
   my $z;
   for ( $z = 0; $z < 32000; $z++) {
      next if vec( $vec, $z, 1);
      vec( $vec, $z, 1) = 1;
      last;
   }
   my $w = Prima::Window-> create(
      name => "Image \$i[$z]",
      menuItems => [['~Image' => [
           [ '~Import' , 'Shift+Ins' , km::Shift | kb::Insert , sub { 
              $_[0]-> Image-> image( $i[ $_[0]->{id}] = $i-> dup); 
           }],
           [ '~Export' , 'Ctrl+Ins' , km::Ctrl | kb::Insert , sub { 
              my $x = $_[0]-> Image-> image; 
              return unless $x;
              $i = $x-> dup;
              show;
           }],
        ],
      ]],
      onDestroy => sub {
         vec( $vec, $_[0]-> {id}, 1) = 0;
      },
   );
   $windows[$z] = $w;
   $w-> {id} = $z;
   $w-> insert( ImageViewer => 
      origin => [0,0],
      size   => [$w-> size],
      hScroll => 1,
      vScroll => 1,
      name    => 'Image',
      quality => 1,
      growMode => gm::Client,
   );
   $w-> select;
   return $w;
}

sub dup
{
   my $img = shift;
   $img = $i unless defined $img;
   show_error('Nothing to dup'), return unless defined $img;
   my $w = window();
   $w-> Image-> image( $i[$w->{id}] = $img-> dup);
}

$w = Prima::Window-> create(
   name => $::application-> name,
   font => { size => 12 },
   onDestroy => sub {
      $::application-> close;
   },
   menuItems =>  [['~Image' => [
      [ '~Open' => 'F3' => 'F3' => sub {
          $fdo = Prima::ImageOpenDialog-> create unless $fdo;
          my $x = $fdo-> load;
          return unless $x;
          $i = $x;
          show;
      }],
      [ '~Save as' => 'F2' => 'F2' => sub {
          return unless $i;
          $fds = Prima::ImageSaveDialog-> create unless $fds;
          $fds-> save( $i);
      }],
      [],
      ['~Duplicate' => 'Ctrl+D' => '^D' => sub { dup(); } ],
   ]]],
);


sub command
{
   my $cmd = $_[0];
   show_error( "");
   if ( $cmd =~ /^(ls|pwd)/) {
      my @ret = split("\n", `$cmd`);
      return unless scalar @ret;
      show_error( $ret[0]);
      print map { "$_\n" } @ret;
      return;
   }
   if ( $cmd =~ /^cd\s*($|\S.*$)/) {
      my $r = length $1 ? $1 : '.';
      chdir $1;
      command('pwd');
      return;
   }
   my @ret;
   eval "{\@ret = $cmd}; die \$\@ if \$\@;";
   show_error($@), return if $@;
   my $ifound;
   for ( @ret) {
      my $z = $_;
      next unless defined $z;
      next unless eval { Prima::Object::alive( $z); };
      next unless $z-> isa( 'Prima::Image');
      if ( $ifound) {
         my $w = window();
         $w-> Image-> image( $i[$w->{id}] = $z);
      } else {
         $i = $z-> dup;
         $ifound = 1;
      }
   }

   $i = Prima::Image-> create if !defined $i || !$i-> isa( 'Prima::Image');
   $j = Prima::Image-> create if !defined $j || !$i-> isa( 'Prima::Image');
   show;
   print "\n" if $cmd =~ /^print/;
}

$w-> insert( Label => 
   width  => $w-> width,
   height => $w-> font-> height,
   bottom => 0,
   left   => 0,
   name   => 'Status',
   text   => '',
   growMode => gm::Floor,
);

my @li = ('quit');
if ( open F, "$HOME/.iterm-list") {
   @li = map { chomp; $_ } <F>; 
   close F;
}

$w-> insert( ComboBox => 
   style  => cs::DropDown,
   width  => $w-> width,
   bottom => $w-> Status-> top + 2,
   left   => 0,
   height => $w-> font-> height + 4,
   text   => '',
   name   => 'Input',
   growMode => gm::Floor,
   editProfile => {
      onKeyDown => sub {
          my ( $self, $code, $key, $mod) = @_;
          if (( $key == kb::Enter) && (( $mod & km::Ctrl & km::Shift & km::Alt) == 0)) {
             my $i = $self-> owner-> List-> items;
             my $t = $self-> text;
             $t =~ s/^\s*//;
             $t =~ s/\s*$//;
             return unless length $t;
             my $found = 0;
             my $ix = 0;
             for ( @$i ) {
                $found = 1, last if $_ eq $t;
                $ix++;
             }
             $self-> owner-> List-> delete_items( $ix) if $found; 
             $self-> owner-> List-> insert_items( 0, $t);
             $self-> text('');
             command( $t);
          }
      },
   },
   listProfile => {
      items => \@li,
      onDestroy => sub {
         if ( open F, "> $HOME/.iterm-list") {
            print F map { "$_\n" } @{$_[0]-> items};
            close F;
         }
      },
   },
);

$w-> insert( ImageViewer => 
   left => 0,
   bottom => $w-> Input-> top + 2,
   width => $w-> width,
   top   => $w-> height,
   hScroll => 1,
   vScroll => 1,
   name    => 'Image',
   quality => 1,
   growMode => gm::Client,
);

#eval { do "$HOME/.iterm-startup"; };
do "$HOME/.iterm-startup";
Prima::MsgBox::message( $@) if @$ ;

command( 'load "' . $ARGV[0] . '"') if @ARGV;

$w-> Input-> select;
while ($::application) {
   eval { run Prima };
   Prima::MsgBox::message( "$@") if $::application && $@;
}

__END__

=pod

=head1 NAME

iterm - the interactive tool for IPA library

=head1 DESCRIPTION

iterm is a mostly command-line tool for basic image processing.
It has terminal representation, where the main window is capable
of viewing the image and accepting commands. The command syntax
is pure perl, plus all functions available in the IPA library
( see L<IPA> ) and Prima toolkit ( see L<Prima>), and some specific
iterm commands.

=head1 USAGE

=head2 Design

iterm defines several scalars for the user needs.
The main window shows the content of the scalar $i, if it is an image.
If the additional windows are opened, they correspond to images in array @i.
The array @i is filled automatically, and the index is shown on 
the additional new window titles. The additional windows are stored in array
@windows, under same indeces. The main window is stored in scalar $w.

The input line is used to enter perl code. If the code returns and newly created
image, it is stored into $i, and the old value of $i is discarded. If the code
returns more than on image, the additional windows opened automatically.
If the code throws an exception, its first line is shown on the status line,
and the whole message is printed to stderr.


=head2 Interactive commands

There are several interactive commands, present on the window menus.

The main and the additional windows have different sets of interactive commands.

=over

=item Open

Presents a file selection dialog, where the image file is to be selected
and its content loaded into variable $i and displayed in the main window.

=item Save as

Opens a file save dialog, where the content of $i can be stored on disk.

=item Duplicate

Creates a new additional window and copies $i into it. The newly created
image is stored into @i array, and the new window into @windows array.
The indeces of these are equal and shown on the window's title.

=item Export

Note: only for additional windows

Copies the content of the image into $i

=item Import

Note: only for additional windows

Copies content of $i into the image.

=back

=head2 iterm commands

These are commands, specific to iterm.

=over

=item new VAR

Assigns new variable $VAR to an empty image

=item show IMAGE

Assigns IMAGE to $i and displays it.

=item clearhistory

Flushes the command history

=item load FILE [ options ]

Loads image FILE into $i and displays the image. FILE must be a quoted string.

=item save IMAGE, FILE [ options ]

Stores IMAGE object into FILE.

=item quit

Exits iterm.

=item zoom SCALE

Selects zoom for window $w. There are no shortcuts for
selecting zoom for the additional windows, but this can be achieved by 
entering the following code:

   $windows[$NUM]-> Image-> zoom($SCALE)

=item window

Opens a new, empty additional window.

=item dup

See L<Duplicate>

=back

=head2 Example

To load an image:

   load 'image.gif'

Convert to 8-bit grayscale:

   $i-> type( im::Byte)

Perform dilation:

   dilate $i

Copy to new window

   dup

Erode the new image

   erode $i[0]

Display the difference

   subtract $i, $i[0]

Note: iterm never asks if the changed images are desired to be saved.

=head1 FILES

~/.iterm-list - the command history

=head1 SEE ALSO

=over

=item *

L<IPA> - the image irocessing library

=item *

L<Prima> - perl graphic toolkit

=back

=head1 AUTHOR

Dmitry Karasik E<lt>dmitry@karasik.eu.orgE<gt>

=cut
