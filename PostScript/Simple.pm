package PostScript::Simple;

use strict;

my $VERSION = 0.01;


=head1 NAME

F<PS.pm> - Produce PostScript files from Perl

=head1 SYNOPSIS

    use PS;
    
    # create a new PostScript object
    $p = new PS(papersize => "A4",
                colour => 1,
                units => "in");
    
    # create a new page
    $p->newpage;
    
    # draw some lines and other shapes
    $p->line(1,1, 1,4);
    $p->linextend(2,4);
    $p->box(1.5,1, 2,3.5);
    $p->circle(2,2, 1);
    
    # draw a rotated polygon in a different colour
    $p->setcolour(0,100,200);
    $p->polygon("rotate=45", 1,1, 1,2, 2,2, 2,1, 1,1);
    
    # add some text in red
    $p->setcolour("red");
    $p->setfont("Times-Roman", 20);
    $p->text(1,1, "Hello");
    
    # write the output to a file
    $p->output("file.ps");

=head1 DESCRIPTION

F<PS.pm> allows you to have a simple method of writing PostScript
files from Perl. It has several graphics primitives that allow
lines, circles, polygons and boxes to be drawn. Text can be
added to the page using standard PostScript fonts.

The images can be single page EPS files, or multipage PostScript
files. The image size can be set by using a recognised paper size
("C<A4>", for example) or by giving dimensions. The units used can
be specified ("C<mm>" or "C<in>", etc) and are the same as those used in
TeX. The default unit is a bp, or a PostScript point, unlike TeX.

It is hoped that one day there may be a GD to PS wrapper, but this
does not currently exist.

=head1 PREREQUISITES

This module requires the C<strict> module.

=head1 PS Methods

=over 4

=cut

# is there another colour database that can be used instead of defining
# this one here? what about the X-windows one? (apart from MS-Win-probs?) XXXXX
my %pscolours = (
  black         => "0    0    0",
  brightred     => "1    0    0",
  brightgreen   => "0    1    0",
  brightblue    => "0    0    1",
  red           => "0.8  0    0",
  green         => "0    0.8  0",
  blue          => "0    0    0.8",
  darkred       => "0.5  0    0",
  darkgreen     => "0    0.5  0",
  darkblue      => "0    0    0.5",
  grey10        => "0.1  0.1  0.1",
  grey20        => "0.2  0.2  0.2",
  grey30        => "0.3  0.3  0.3",
  grey40        => "0.4  0.4  0.4",
  grey50        => "0.5  0.5  0.5",
  grey60        => "0.6  0.6  0.6",
  grey70        => "0.7  0.7  0.7",
  grey80        => "0.8  0.8  0.8",
  grey90        => "0.9  0.9  0.9",
  white         => "1    1    1",
);

# define page sizes here (a4, letter, etc) XXXXX
# should be Properly Cased
my %pspaper = (
  A3            => "841.88976 1190.5512",
  A4            => "595.27559 841.88976",
  A5            => "420.94488 595.27559",
  Letter        => "612 792",
);

# measuring units are two-letter acronyms as used in TeX:
#  bp: postscript point (72 per inch)
#  in: inch (72 postscript points)
#  pt: printer's point (72.27 per inch)
#  mm: millimetre (25.4 per inch)
#  cm: centimetre (2.54 per inch)
#  pi: pica (12 printer's points)

#  set up the others here (dd, cc, sp) XXXXX

my %psunits = (
  pt => "72 72.27",
  pc => "72 6.0225",
  in => "72 1",
  bp => "1 1",
  cm => "72 2.54",
  mm => "72 25.4",
);


=item C<new(options)>

Create a new PostScript object. The different options that can be set are:

=over 4

=item units

Units that are to be used in the file. Common units would be C<mm>, C<in>,
C<pt>, C<bp>, and C<cm>. Others are as used in TeX. (Default: C<bp>)

=item xsize

Specifies the width of the drawing area in units.

=item ysize

Specifies the height of the drawing area in units.

=item papersize

The size of paper to use, if C<xsize> or C<ysize> are not defined. This allows
a document to easily be created using a standard paper size without having to
remember the size of paper using PostScript points. Valid choices are currently
"C<A3>", "C<A4>", "C<A5>", and "C<Letter>".

=item landscape

Use the landscape option to rotate the page by 90 degrees. The paper dimensions
are also rotated, so that clipping will still work. (Default: 0)

=item clip

If set to 1, the image will be clipped to the xsize and ysize. This is most
useful for an EPS image. (Default: 0)

=item colour

Specifies whether the image should be rendered in colour or not. If set to 0
(default) all requests for a colour are mapped to a greyscale. Otherwise the
colour requested with C<setcolour> or C<line> is used. This option is present
because most modern laser printers are only black and white. (Default: 0)

=item eps

Generate an EPS file, rather than a standard PostScript file. If set to 1, no
newpage methods will actually create a new page. This option is probably the
most useful for generating images to be imported into other applications, such
as TeX. (Default: 1)

=item page

Specifies the initial page number of the (multi page) document. The page number
is set with the Adobe DSC comments, and is used nowhere else. It only makes
finding your pages easier. See also the C<newpage> method. (Default: 1)

=back

Example:

    $ref = new PS(landscape => 1,
                  eps => 0,
                  xsize => 4,
                  ysize => 3,
                  units => "in");

Create a document that is 4 by 3 inches and prints landscape on a page. It is
not an EPS file, and must therefore use the C<newpage> method.

    $ref = new PS(eps => 1,
                  colour => 1,
                  xsize => 12,
                  ysize => 12,
                  units => "cm");

Create a 12 by 12 cm EPS image that is in colour. Note that "C<eps =E<gt> 1>" does
not have to be specified because this is the default.

=cut

sub new
{
  my ($class, %data) = @_;
  my %fields = (
    xsize        => undef,
    ysize        => undef,
    papersize    => undef,
    units        => "bp",     # measuring units (see below)
    landscape    => 0,        # rotate the page 90 degrees
    colour       => 0,        # use colour
    clip         => 0,        # clip to the bounding box
    eps          => 1,        # create eps file
    page         => 1,        # page number to start at

    bbx1         => 0,        # Bounding Box definitions
    bby1         => 0,
    bbx2         => 0,
    bby2         => 0,

    pscomments   => "",       # the following entries store data
    psprolog     => "",       # for the same DSC areas of the
    psfunctions  => "",       # postscript file.
    pssetup      => "",
    pspages      => "",
    pstrailer    => "",

    pspagecount  => 0,
    usedcircle   => 0,
    usedbox      => 0,
    usedrotabout => 0,
  );

  foreach (keys %data)
  {
    $fields{$_} = $data{$_};
  }

  my $self = bless {%fields}, $class;

  $self->init();

  $self->{used_circle} = 0;

  return $self;
}

sub init
{
  my $self = shift;

  my ($m, $d) = (1, 1);
  my $u;

# Units
  if (defined $self->{units})
  {
    $self->{units} = lc $self->{units};
  }

  if (defined($psunits{$self->{units}}))
  {
    ($m, $d) = split(/\s+/, $psunits{$self->{units}});
  }
  else
  {
    $self->{pspages} .= "(error: unit \"$self->{units}\" undefined\n) print flush\n";
  }

  $u = "{";
  if ($m != 1) { $u .= "$m mul " }
  if ($d != 1) { $u .= "$d div " }
  $u =~ s/ $//;
  $u .="}";
  
  $self->{psfunctions} .= "/u $u def\n";

# Paper size
  if (defined $self->{papersize})
  {
    $self->{papersize} = ucfirst lc $self->{papersize};
  }

  if (!defined $self->{xsize} || !defined $self->{ysize})
  {
    if (defined $self->{papersize} && defined $pspaper{$self->{papersize}})
    {
      ($self->{xsize}, $self->{ysize}) = split(/\s+/, $pspaper{$self->{papersize}});
      $self->{bbx2} = int($self->{xsize});
      $self->{bby2} = int($self->{ysize});
      $self->{pscomments} .= "\%\%DocumentMedia: $self->{papersize} $self->{xsize} ";
      $self->{pscomments} .= "$self->{ysize} 0 ( ) ( )\n";
     }
    else
    {
      ($self->{xsize}, $self->{ysize}) = (100,100);
      $self->{pspages} .= "(error: page size undefined\n) print flush\n"; # XXXXX ps comment?
    }
  }
  else
  {
    $self->{bbx2} = int(($self->{xsize} * $m) / $d);
    $self->{bby2} = int(($self->{ysize} * $m) / $d);
  }

# Landscape
  if ($self->{landscape})
  {
    my $swap;
    $self->{psfunctions} .= "/landscape {
  $self->{bbx2} 0 translate
  90 rotate
} bind def
";
    $self->{pscomments} .= "\%\%Orientation: Landscape\n";
    $swap = $self->{bbx2};
    $self->{bbx2} = $self->{bby2};
    $self->{bby2} = $swap;
    # for EPS files, change to landscape here, as there are no pages
    if ($self->{eps}) { $self->{pssetup} .= "landscape\n" }
  }
  else
  {
    $self->{pscomments} .= "\%\%Orientation: Portrait\n";
  }
  
# Clipping
  if ($self->{clip})
  {
    $self->{psfunctions} .= "/pageclip {newpath $self->{bbx1} $self->{bby1} moveto
$self->{bbx1} $self->{bby2} lineto
$self->{bbx2} $self->{bby2} lineto
$self->{bbx2} $self->{bby1} lineto
$self->{bbx1} $self->{bby1} lineto
closepath clip} bind def
";
    if ($self->{eps}) { $self->{pssetup} .= "pageclip\n" }
  }
}


=item C<newpage([number])>

Generates a new page on a PostScript file. If specified, C<number> gives
the number (or name) of the page.

The page number is automatically incremented each time this is called without
a new page number, or decremented if the current page number is negative.

Example:

    $p->newpage(1);
    $p->newpage;
    $p->newpage("hello");
    $p->newpage(-6);
    $p->newpage;

will generate five pages, numbered: 1, 2, "hello", -6, -7.

=cut

sub newpage
{
  my $self = shift;
  my $nextpage = shift;
  
  if (defined($nextpage))
  {
    $self->{page} = $nextpage;
  }

  if ($self->{eps})
  {
# Cannot have multiple pages in an EPS file XXXXX
    return 0;
  }

  if ($self->{pspagecount} != 0)
  {
    $self->{pspages} .= "\%\%PageTrailer\n";
    $self->{pspages} .= "pagelevel restore\n";
    $self->{pspages} .= "showpage\n";
  }

  $self->{pspagecount} ++;
  $self->{pspages} .= "\%\%Page: $self->{page} $self->{pspagecount}\n";
  if ($self->{page} >= 0)
  {    
    $self->{page} ++;
  }
  else
  {
    $self->{page} --;
  }

  $self->{pspages} .= "\%\%BeginPageSetup\n";
  $self->{pspages} .= "/pagelevel save def\n";
  if ($self->{landscape}) { $self->{pspages} .= "landscape\n" }
  if ($self->{clip}) { $self->{pspages} .= "pageclip\n" }
  $self->{pspages} .= "\%\%EndPageSetup\n";
}


=item C<output(filename)>

Writes the current PostScript out to the file named C<filename>. Will destroy
any existing file of the same name.

Use this option whenever output is required to disk. The current PostScript
document in memory is not cleared, and can still be extended.

=cut

sub output
{
  my $self = shift;
  my $file = shift;
  
  my $eps = $self->{eps};
  my $date = scalar localtime;
  my $user = getlogin;

  open OUT, "> $file";

# Comments Section
  print OUT "%!PS-Adobe-3.0";
  if ($eps) { print OUT " EPSF-1.2" }
  print OUT "\n";
  print OUT "\%\%Title: ($file)\n";
  print OUT "\%\%LanguageLevel: 1\n";
  print OUT "\%\%Creator: PS.pm perl module by Matthew Newton and Mark Withall\n";
  print OUT "\%\%CreationDate: $date\n";
  print OUT "\%\%For: $user\n";
  print OUT $self->{pscomments};
#  print OUT "\%\%DocumentFonts: \n";
  if ($eps)
  {
    print OUT "\%\%Pages: 1\n";
    print OUT "\%\%BoundingBox: $self->{bbx1} $self->{bby1} $self->{bbx2} $self->{bby2}\n";
  }
  else
  {
    print OUT "\%\%Pages: $self->{pspagecount}\n";
  }
  print OUT "\%\%EndComments\n";
  
# Prolog Section
  print OUT "\%\%BeginProlog\n";
  print OUT $self->{psprolog};
  print OUT "\%\%BeginResource: PS.pm\n";
  print OUT $self->{psfunctions};
  print OUT "\%\%EndResource\n";
  print OUT "\%\%EndProlog\n";

# Setup Section
  if (length($self->{pssetup}))
  {
    print OUT "\%\%BeginSetup\n";
    print OUT $self->{pssetup};
    print OUT "\%\%EndSetup\n";
  }

# Pages
  print OUT $self->{pspages};
  if ((!$eps) && ($self->{pspagecount} > 0))
  {
    print OUT "\%\%PageTrailer\n";
    print OUT "pagelevel restore\n";
    print OUT "showpage\n";
  }

# Trailer Section
  if (length($self->{pstrailer}))
  {
    print OUT "\%\%Trailer\n";
    print OUT $self->{pstrailer};
  }
  print OUT "\%\%EOF\n";
  close OUT;
}


=item C<setcolour((red, green, blue)|(name))>

Sets the new drawing colour to the values specified in C<red>, C<green> and
C<blue>. The values range from 0 to 255.

Alternatively, a colour name may be specified. Those currently defined are
listed at the top of F<PS.pm> in the C<%pscolours> hash.

Example:

    # set new colour to brown
    $p->setcolour(200,100,0);
    # set new colour to black
    $p->setcolour("black");

=cut

sub setcolour
{
  my $self = shift;
  my ($r, $g, $b) = @_;
  my $i;

  if (defined ($r) and !defined ($g) and !defined ($b))
  {
    $r = lc $r;

    if (defined $pscolours{$r})
    {
      ($r, $g, $b) = split(/\s+/, $pscolours{$r});
    }
    else
    {
# error: bad colour XXXXX
      $self->{pspages} .= "(error: bad colour name \"$r\"\n) print flush\n";
      return 0;
    }
  }
  elsif (defined ($r) and defined ($g) and defined ($b))
  {
    $r /= 255;
    $g /= 255;
    $b /= 255;
  }
  else
  {
# error: invalid arguments XXXXX
    return 0;
  }

  if ($self->{colour})
  {
    $self->{pspages} .= "$r $g $b setrgbcolor\n";
  }
  else
  {
    $r = ($r + $g + $b) / 3;
    $self->{pspages} .= "$r setgray\n";
  }
}


=item C<setlinewidth(width)>

Sets the new line width to C<width> units.

Example:

    # draw a line 10mm long and 4mm wide
    $p = new PS(units => "mm");
    $p->setlinewidth(4);
    $p->line(10,10, 20,10);

=cut

sub setlinewidth
{
  my $self = shift;

  my $width = shift;

  if ($width eq "thin") { $width = "0.4" }
  else { $width .= " u" }

  $self->{pspages} .= "$width setlinewidth\n";
}

=item C<line(x1,y1, x2,y2 [,red, green, blue])>

Draws a line from the co-ordinates (x1,x2) to (x2,y2). If values are specified
for C<red>, C<green> and C<blue>, then the colour is set before the line is drawn.

Example:

    # set the colour to black
    $p->setcolour("black");

    # draw a line in the current colour (black)
    $p->line(10,10, 10,20);
    
    # draw a line in red
    $p->line(20,10, 20,20, 255,0,0);

    # draw another line in red
    $p->line(30,10, 30,20);

=cut

sub line
{
  my $self = shift;
  my ($x1, $y1, $x2, $y2, $r, $g, $b) = @_;
# dashed lines? XXXXX

  if ((!$self->{pspagecount}) and (!$self->{eps}))
  {
# Cannot draw on to non-page when not an eps file XXXXX
    return 0;
  }

  if (defined ($r) and defined ($g) and defined ($b))
  {
    $self->setcolour($r, $g, $b);
  }

  $self->{pspages} .= "newpath $x1 u $y1 u moveto $x2 u $y2 u lineto stroke\n";
}


=item C<linextend(x,y)>

Assuming the previous command was C<line> or C<linextend>, extend that line to include
another segment to the co-ordinates (x,y). Behaviour after any other method is unspecified.

Example:

    $p->line(10,10, 10,20);
    $p->linextend(20,20);
    $p->linextend(20,10);
    $p->linextend(10,10);

Notes

The C<polygon> method may be more appropriate.

=cut


sub linextend
{
  my $self = shift;
  my ($x, $y) = @_;
  
  $self->{pspages} =~ s/ lineto stroke.*$/ lineto\n$x u $y u lineto stroke/;
#  $self->{pspages} .= "$x u $y u lineto stroke\n";
# XXXXX
}


=item C<polygon(["options",] x1,y1, x2,y2, ..., xn,yn [,filled])>

The C<polygon> method is multi-function, allowing many shapes to be created and
manipulated. Polygon draws lines from (x1,y1) to (x2,y2) and then from (x2,y2) to
(x3,y3) up to (xn-1,yn-1) to (xn,yn).

If the value of C<filled> is 1 then the PostScript output is set to fill the object
rather than just draw the lines.

The options may be set as follows. Note that no whitespace may appear in each
option, which must be specified as name=value1,value2. Each option must be
separated by whitespace.

=over 4

=item rotate=angle[,x,y]

Rotate the polygon by C<angle> degrees anti-clockwise. If x and y are specified
then use the co-ordinate (x,y) as the centre of rotation, otherwise use the co-ordinate
(x1,y1) from the main polygon.

=item filled=1

Synonymous with the option C<filled> above.

=item offset=x,y

Displace the object by the vector (x,y).

=back

Example:

    # draw a square with lower left point at (10,10)
    $p->polygon(10,10, 10,20, 20,20, 20,10, 10,10);

    # draw a filled square with lower left point at (20,20)
    $p->polygon("offset=10,10", 10,10, 10,20, 20,20, 20,10, 10,10, 1);

    # draw a filled square with lower left point at (10,10)
    # rotated 45 degrees
    $p->polygon("rotate=45 filled=1", 10,10, 10,20,
                20,20, 20,10, 10,10);

=cut

sub polygon
{
  my $self = shift;
  my ($xoffset, $yoffset) = (0,0);
  my @options = ();
  my $i;
  my ($rotate, $rotatex, $rotatey) = (0,0,0);
  my $filled = 0;

  if ($#_ < 3)
  {
# cannot have polygon with just one point...
    $self->{pspages} .= "(error: bad polygon definition\n) print flush\n";
    return 0;
  }

  my $x = shift;
  my $y = shift;

  if ($x =~ /=/) {
    @options = split(/ /, $x);
    $x = $y;
    $y = shift;
  }

  foreach $i (@options)
  {
    if ($i =~ /^offset=([-\.\d]*),([-\.\d]*)$/) {
      $xoffset = $1;
      $yoffset = $2;
    }
    elsif ($i =~ /^rotate=([-\.\d]*)(,([-\.\d]*),([-\.\d]*))?$/) {
      $rotate = $1;
      if (defined($2))
      {
        $rotatex = $3;
        $rotatey = $4;
      }
      else
      {
        $rotatex = $x;
        $rotatey = $y;
      }
    }
    elsif ($i =~ /^filled=1$/) {
      $filled = 1;
    }
  }

  if (!defined($x) || !defined($y))
  {
    $self->{pspages} .= "(error: bad polygon definition\n) print flush\n";
    return 0;
  }

  if ($xoffset || $yoffset || $rotate)
  {
    $self->{pspages} .= "gsave ";
  }

  if ($xoffset || $yoffset)
  {
    $self->{pspages} .= "$xoffset u $yoffset u translate\n";
  }

  if ($rotate)
  {
    if (!$self->{usedrotabout})
    {
      $self->{psfunctions} .= "/rotabout {3 copy pop translate rotate exch 0 exch
sub exch 0 exch sub translate} def\n";
      $self->{usedrotabout} = 1;
    }

    $self->{pspages} .= "$rotatex u $rotatey u $rotate rotabout\n";
#    $self->{pspages} .= "gsave $rotatex u $rotatey u translate ";
#    $self->{pspages} .= "$rotate rotate -$rotatex u -$rotatey u translate\n";
  }
  
  $self->{pspages} .= "newpath $x u $y u moveto\n";
  
  while ($#_ > 0)
  {
    my $x = shift;
    my $y = shift;
    
    $self->{pspages} .= "$x u $y u lineto ";
  }

  $x = shift;

  if ($filled || (defined($x) && $x == 1))
  {
    $self->{pspages} .= "fill\n";
  }
  else
  {
    $self->{pspages} .= "stroke\n";
  }

  if ($xoffset || $yoffset || $rotate)
  {
    $self->{pspages} .= "grestore\n";
  }
}


=item C<circle(x,y, r [,filled])>

Plot a circle with centre at (x,y) and radius of r.

If C<filled> is 1 then fill the circle.

Example:

    $p->circle(40,40, 20);

=cut

sub circle
{
  my $self = shift;

  my ($x, $y, $r, $filled) = @_;

  if (!defined $filled) { $filled = 0 }
  
  if (!$self->{usedcircle})
  {
    $self->{psfunctions} .= "/circle {newpath 0 360 arc closepath} bind def\n";
    $self->{usedcircle} = 1;
  }

  $self->{pspages} .= "$x u $y u $r u circle ";
  if ($filled) { $self->{pspages} .= "fill\n" }
  else {$self->{pspages} .= "stroke\n" }
}


=item C<box(x1,y1, x2,y2 [,filled])>

Draw a rectangle from lower left co-ordinates (x1,y1) to upper right
co-ordinates (y1,y2). If C<filled> is 1 then fill the rectangle.

Example:

    $p->box(10,10, 20,30);

Notes

The C<polygon> method is far more flexible, but this method is quicker!

=cut

sub box
{
  my $self = shift;

  my ($x1, $y1, $x2, $y2, $filled) = @_;

  if (!defined $filled) { $filled = 0 }
  
  if (!$self->{usedbox})
  {
    $self->{psfunctions} .= "/box {
  newpath 3 copy pop exch 4 copy pop pop
  8 copy pop pop pop pop exch pop exch
  3 copy pop pop exch moveto lineto
  lineto lineto pop pop pop pop closepath
} bind def
";
    $self->{usedbox} = 1;
  }

  $self->{pspages} .= "$x1 u $y1 u $x2 u $y2 u box ";
  if ($filled) { $self->{pspages} .= "fill\n" }
  else {$self->{pspages} .= "stroke\n" }
}


=item C<setfont(font, size)>

Set the current font to the PostScript font C<font>. Set the size in PostScript
points to C<size>.

Notes

This method must be called on every page before the C<text> method is used.

=cut

sub setfont
{
  my $self = shift;
  my ($name, $size, $ysize) = @_;

# set font y size XXXXX

  $self->{pspages} .= "/$name findfont $size scalefont setfont\n";
}


=item C<text(x,y, string)>

Plot text on the current page with the lower left co-ordinates at (x,y). The
text is specified in C<string>.

Example:

    $p->setfont("Times-Roman", 12);
    $p->text(40,40, "The frog sat on the leaf in the pond.");

Bugs

The text method does not currently support using some non-alphanumeric characters,
notably parentheses.

=cut

sub text
{
  my $self = shift;
  my ($x, $y, $text) = @_;

# handle text with ( and ) in it already XXXXX

  $self->{pspages} .= "newpath $x u $y u moveto ($text) show stroke\n";
}


# Display method for debugging internal variables
#
#sub display {
#  my $self = shift;
#  my $i;
#
#  foreach $i (keys(%{$self}))
#  {
#    print "$i = $self->{$i}\n";
#  }
#}


1;

=back

=head1 BUGS

Some current functionality may not be as expected, and/or may not work correctly.

More functions need to be added. See the bottom of the F<PS.pm> file.

=head1 AUTHOR

The F<PS.pm> perl module was written by Matthew Newton, with a small amount of help
and suggestions from Mark Withall.

The idea for the module came from the two aforementioned whilst (apparently) thinking.


=cut




# To-Do / Done list:

# Done:

#   landscape seems to work ok
#   xsize and ysize set fine
#   colour option works. need to alter colour->grey calculation (i know how to)
#   clipping works
#   eps option works (but output needs slight modification save/restore etc)
#   page option works. setpage allows page number/name to be changed
#   bb[xy][12] options are in and set
#   lines, circles and boxes work. functions only added when needed.
#   setcolour function works. colour look-up table added.
#   postscript DSC headers seem to be fine (for PS and EPS)
#   colour->grey calculation (tested: this is actually ok)
#   is this cool or wot?
#   different line widths
#   polygon function
#   text and font functions

# To-Do:

#   define shape functions
#   translate / scale / rotate functions?
#   gd wrapper module
#
#   triangle function(s)
#   add dd cc and sp to units
#   different line styles (dashes)?
#   better error reporting (postscript comments still?)
#   code compression using single letter dictionary defs (optional?)
#   my-printer-can-play-jingle-bells-now function?
#   paper sizes defined and used (DSC comment added)
#   postscript font support?
#   ttf font support (get lost!)
#   any postscript optimisation that can be done?
#   (compare gd module for functions that we could do with)
#   pie slices / arcs
#   how about "write this out as a PDF file" option?
#   write out as xfig file option?
#   write out as LaTeX picture (XYPic?) file option?
#   release as version 0.03 (or similar)

