#!/usr/bin/perl -w

use strict;
use lib qw(./lib ../lib t/lib);
use Test::Simple tests => 3;
#use Data::Dumper;
use PostScript::Simple;

my $f = "xtest-c.ps";
my $p = new PostScript::Simple(papersize => "a4",
            colour => 1,
            units => "in",
            reencode => undef);

ok( $p );

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
$p->output( $f );

ok( -e $f );

open( FILE, $f ) or die("Can't open $f: $!");
my $lines;
while (<FILE>) {
	next if m/^%%/;
	$lines .= $_;
}
close FILE;

ok( $lines eq CANNED() );

###

sub CANNED {
return q[%!PS-Adobe-3.0 EPSF-1.2
/u {72 mul} def
/box {
  newpath 3 copy pop exch 4 copy pop pop
  8 copy pop pop pop pop exch pop exch
  3 copy pop pop exch moveto lineto
  lineto lineto pop pop pop pop closepath
} bind def
/circle {newpath 0 360 arc closepath} bind def
/rotabout {3 copy pop translate rotate exch 0 exch
sub exch 0 exch sub translate} def
(error: Do not use newpage for eps files!
) print flush
newpath
1 u 1 u moveto
1 u 4 u lineto
2 u 4 u lineto stroke
1.5 u 1 u 2 u 3.5 u box stroke
2 u 2 u 1 u circle stroke
0 0.392156862745098 0.784313725490196 setrgbcolor
gsave 1 u 1 u 45 rotabout
newpath
1 u 1 u moveto
1 u 2 u lineto 2 u 2 u lineto 2 u 1 u lineto 1 u 1 u lineto stroke
grestore
0.8 0 0 setrgbcolor
/Times-Roman findfont 20 scalefont setfont
newpath
1 u 1 u moveto
(Hello) show stroke
];
}

