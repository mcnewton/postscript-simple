#!/usr/bin/perl
use strict;
use lib qw(./lib ../lib t/lib);
use Test::Simple tests => 43;
use Data::Dumper;
use PostScript::Simple;

# huge workout of all methods, OK and error conditions

my $s = new PostScript::Simple(xsize => 350, ysize => 350, eps => 1, colour => 1);

ok( $s );
ok( ! $s->newpage );

eval { $s->output; };
ok( $@ );

ok( $s->setcolour('black') );
ok( $s->setcolour('BLACK') );
ok( ! $s->setcolour('Geddy lee') );
ok( ! $s->setcolour(120, 240) );
ok( $s->setcolour(120, 240, 0) );


ok( $s->setlinewidth(1) );
ok( ! $s->setlinewidth );


ok( $s->line(10,10, 10,20) );
ok( ! $s->line(10,10, 10,20, 50, 50) );
ok( ! $s->line(10,10, 10) );
ok( $s->line(10,10, 10,20, 50, 50, 50) );


ok( $s->linextend(100,100) );
ok( ! $s->linextend(100) );


ok( $s->polygon(10,10, 10,20, 110,10, 110,20) );
ok( $s->polygon(10,10, 10,20, 110,10, 110,20, 1) );
ok( $s->polygon("rotate=45 filled=1", 10,10, 10,20, 110,10, 110,20) );
ok( $s->polygon("rotate=45,20,20", 10,10, 10,20, 110,10, 110,20) );
ok( $s->polygon("offset=10,10", 10,10, 10,20, 110,10, 110,20) );
ok( ! $s->polygon(10,10, 10) );


ok( $s->circle( 120, 120, 30 ) );
ok( $s->circle( 120, 120, 30, 1 ) );
ok( ! $s->circle( 120 ) );
ok( ! $s->circle );


ok( $s->box(210,210, 220,230) );
ok( $s->box(215,215, 225,235, 1) );
ok( ! $s->box(210,210, 220) );


ok( $s->setfont('Helvetica', 12) );
ok( ! $s->setfont('Helvetica') );


ok( $s->text( 10, 10, 'Hello World' ) );
ok( ! $s->text( 10, 10, 'Hello World', 'foo' ) );
ok( ! $s->text( 10, 10 ) );


ok( ! $s->curve(10,310, 10,320, 110,310, 110) );
ok( $s->curve(10,310, 10,320, 110,310, 110,320) );


ok( $s->curvextend(110,330, 210,330, 210,320) );
ok( ! $s->curvextend(110,330, 210,330, 210) );


ok( length($s->{'pspages'}) eq length(CANNED()) );
ok( $s->{'pspages'} eq CANNED() );

ok( length($s->{'psfunctions'}) eq length(FUNCS()) );
ok( $s->{'psfunctions'} eq FUNCS() );

ok( $s->output('x03.eps') );
unlink 'x03.eps';

#print Dumper $s;

###

sub FUNCS {
return '/u {} def
/rotabout {3 copy pop translate rotate exch 0 exch
sub exch 0 exch sub translate} def
/circle {newpath 0 360 arc closepath} bind def
/box {
  newpath 3 copy pop exch 4 copy pop pop
  8 copy pop pop pop pop exch pop exch
  3 copy pop pop exch moveto lineto
  lineto lineto pop pop pop pop closepath
} bind def
';
}

sub CANNED {
return '0 0 0 setrgbcolor
0 0 0 setrgbcolor
(error: bad colour name \'geddy lee\'
) print flush
(error: setcolour given invalid arguments: 120, 240, undef
) print flush
0.470588235294118 0.941176470588235 0 setrgbcolor
1 u setlinewidth
(error: setlinewidth not given a width
) print flush
newpath
10 u 10 u moveto
10 u 20 u lineto stroke
(error: wrong number of args for line
) print flush
(error: wrong number of args for line
) print flush
0.196078431372549 0.196078431372549 0.196078431372549 setrgbcolor
newpath
10 u 10 u moveto
10 u 20 u lineto
100 u 100 u lineto stroke
(error: wrong number of args for linextend
) print flush
newpath
10 u 10 u moveto
10 u 20 u lineto 110 u 10 u lineto 110 u 20 u lineto stroke
newpath
10 u 10 u moveto
10 u 20 u lineto 110 u 10 u lineto 110 u 20 u lineto fill
gsave 10 u 10 u 45 rotabout
newpath
10 u 10 u moveto
10 u 20 u lineto 110 u 10 u lineto 110 u 20 u lineto fill
grestore
gsave 20 u 20 u 45 rotabout
newpath
10 u 10 u moveto
10 u 20 u lineto 110 u 10 u lineto 110 u 20 u lineto stroke
grestore
gsave 10 u 10 u translate
newpath
10 u 10 u moveto
10 u 20 u lineto 110 u 10 u lineto 110 u 20 u lineto stroke
grestore
(error: bad polygon - not enough points
) print flush
120 u 120 u 30 u circle stroke
120 u 120 u 30 u circle fill
(error: not enough args for circle
) print flush
(error: not enough args for circle
) print flush
210 u 210 u 220 u 230 u box stroke
215 u 215 u 225 u 235 u box fill
(error: insufficient arguments for box
) print flush
/Helvetica findfont 12 scalefont setfont
(error: wrong number of arguments for setfont
) print flush
newpath
10 u 10 u moveto
(Hello World) show stroke
(error: wrong number of arguments for text
) print flush
(error: wrong number of arguments for text
) print flush
(error: bad curve definition, wrong number of args
) print flush
newpath
10 u 310 u moveto
10 u 320 u 110 u 310 u 110 u 320 u curveto
110 u 330 u 210 u 330 u 210 u 320 u curveto stroke
(error: bad curveextend definition, wrong number of args
) print flush
';
}
