#!/usr/bin/perl -w

use strict;
use lib qw(./lib ../lib t/lib);
use Test::Simple tests => 11;
#use Data::Dumper;
use PostScript::Simple;

my $f = "xtest-b.ps";
my $t = new PostScript::Simple(landscape => 0,
            eps => 0,
            papersize => "a4",
            colour => 1,
            clip => 0,
            units => "mm");

ok( $t );

$t->newpage(-1);

$t->line(10,10, 10,50);
$t->setlinewidth(8);
$t->line(90,10, 90,50);
$t->linextend(40,90);
$t->setcolour("brightred");
$t->circle(40, 90, 30, 1);
$t->setcolour("darkgreen");
$t->setlinewidth(0.1);
for (my $i = 0; $i < 360; $i += 20) {
  $t->polygon("offset=0,0 rotate=$i,70,90 filled=0", 40,90, 69,92, 75,84);
}

$t->setlinewidth("thin");
$t->setcolour("darkgreen");
$t->box(20, 10, 80, 20);
$t->setcolour("grey30");
$t->box(20, 30, 80, 40, 1);
$t->setcolour("grey10");
$t->setfont("Bookman", 12);
$t->text(5,5, "Matthew");

$t->newpage;
$t->line((10, 20), (30, 40));
$t->linextend(60, 50);

$t->line(10,12, 20,12);
$t->polygon(10,10, 20,10);

$t->setcolour("grey90");
$t->polygon("offset=5,5 filled=1", 10,10, 15,20, 25,20, 30,10, 15,15, 10,10, 0);
$t->setcolour("black");
$t->polygon("offset=10,10 rotate=45,20,20", 10,10, 15,20, 25,20, 30,10, 15,15, 10,10, 1);

$t->line((0, 100), (100, 0), (255, 0, 0));

$t->newpage(30);

for (my $i = 12; $i < 80; $i += 2) {
  $t->setcolour($i*3, 0, 0);
  $t->box($i - 2, 10, $i, 40, 1);
}

$t->line((40, 30), (30, 10));
$t->linextend(60, 0);
$t->line((0, 100), (100, 0),(0, 255, 0));

$t->output( $f );

ok( -e $f );

open( FILE, $f ) or die("Can't open $f: $!");
$/ = undef;
my $lines = <FILE>;
close FILE;

ok( $lines =~ m/%%LanguageLevel: 1/s );
ok( $lines =~ m/%%DocumentMedia: A4 595.27559 841.88976 0 \( \) \( \)/s );
ok( $lines =~ m/%%Orientation: Portrait/s );
ok( $lines =~ m/%%Pages: 3/s );

ok( index($lines, "%!PS-Adobe-3.0\n") == 0 );
my ( $prolog ) = ( $lines =~ m/%%BeginResource: PostScript::Simple\n(.*)%%EndResource/s );
ok( $prolog );
ok( $prolog eq PROLOG());

my ( $body ) = ( $lines =~ m/%%EndProlog\n(.*)%%EOF/s );
ok( $body );
ok( $body eq BODY());

#print ">>>$body<<<<<<\n";

### Subs

sub PROLOG {
	return q[/u {72 mul 25.4 div} def
/circle {newpath 0 360 arc closepath} bind def
/rotabout {3 copy pop translate rotate exch 0 exch
sub exch 0 exch sub translate} def
/box {
  newpath 3 copy pop exch 4 copy pop pop
  8 copy pop pop pop pop exch pop exch
  3 copy pop pop exch moveto lineto
  lineto lineto pop pop pop pop closepath
} bind def
];
}

sub BODY {
	return q[%%Page: -1 1
%%BeginPageSetup
/pagelevel save def
%%EndPageSetup
newpath
10 u 10 u moveto
10 u 50 u lineto stroke
8 u setlinewidth
newpath
90 u 10 u moveto
90 u 50 u lineto
40 u 90 u lineto stroke
1 0 0 setrgbcolor
40 u 90 u 30 u circle fill
0 0.5 0 setrgbcolor
0.1 u setlinewidth
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
gsave 70 u 90 u 20 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 40 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 60 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 80 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 100 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 120 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 140 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 160 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 180 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 200 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 220 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 240 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 260 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 280 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 300 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 320 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
gsave 70 u 90 u 340 rotabout
newpath
40 u 90 u moveto
69 u 92 u lineto 75 u 84 u lineto stroke
grestore
0.4 setlinewidth
0 0.5 0 setrgbcolor
20 u 10 u 80 u 20 u box stroke
0.3 0.3 0.3 setrgbcolor
20 u 30 u 80 u 40 u box fill
0.1 0.1 0.1 setrgbcolor
/Bookman findfont 12 scalefont setfont
newpath
5 u 5 u moveto
(Matthew) show stroke
%%PageTrailer
pagelevel restore
showpage
%%Page: -2 2
%%BeginPageSetup
/pagelevel save def
%%EndPageSetup
newpath
10 u 20 u moveto
30 u 40 u lineto
60 u 50 u lineto stroke
newpath
10 u 12 u moveto
20 u 12 u lineto stroke
newpath
10 u 10 u moveto
20 u 10 u lineto stroke
0.9 0.9 0.9 setrgbcolor
gsave 5 u 5 u translate
newpath
10 u 10 u moveto
15 u 20 u lineto 25 u 20 u lineto 30 u 10 u lineto 15 u 15 u lineto 10 u 10 u lineto fill
grestore
0 0 0 setrgbcolor
gsave 10 u 10 u translate
20 u 20 u 45 rotabout
newpath
10 u 10 u moveto
15 u 20 u lineto 25 u 20 u lineto 30 u 10 u lineto 15 u 15 u lineto 10 u 10 u lineto fill
grestore
1 0 0 setrgbcolor
newpath
0 u 100 u moveto
100 u 0 u lineto stroke
%%PageTrailer
pagelevel restore
showpage
%%Page: 30 3
%%BeginPageSetup
/pagelevel save def
%%EndPageSetup
0.141176470588235 0 0 setrgbcolor
10 u 10 u 12 u 40 u box fill
0.164705882352941 0 0 setrgbcolor
12 u 10 u 14 u 40 u box fill
0.188235294117647 0 0 setrgbcolor
14 u 10 u 16 u 40 u box fill
0.211764705882353 0 0 setrgbcolor
16 u 10 u 18 u 40 u box fill
0.235294117647059 0 0 setrgbcolor
18 u 10 u 20 u 40 u box fill
0.258823529411765 0 0 setrgbcolor
20 u 10 u 22 u 40 u box fill
0.282352941176471 0 0 setrgbcolor
22 u 10 u 24 u 40 u box fill
0.305882352941176 0 0 setrgbcolor
24 u 10 u 26 u 40 u box fill
0.329411764705882 0 0 setrgbcolor
26 u 10 u 28 u 40 u box fill
0.352941176470588 0 0 setrgbcolor
28 u 10 u 30 u 40 u box fill
0.376470588235294 0 0 setrgbcolor
30 u 10 u 32 u 40 u box fill
0.4 0 0 setrgbcolor
32 u 10 u 34 u 40 u box fill
0.423529411764706 0 0 setrgbcolor
34 u 10 u 36 u 40 u box fill
0.447058823529412 0 0 setrgbcolor
36 u 10 u 38 u 40 u box fill
0.470588235294118 0 0 setrgbcolor
38 u 10 u 40 u 40 u box fill
0.494117647058824 0 0 setrgbcolor
40 u 10 u 42 u 40 u box fill
0.517647058823529 0 0 setrgbcolor
42 u 10 u 44 u 40 u box fill
0.541176470588235 0 0 setrgbcolor
44 u 10 u 46 u 40 u box fill
0.564705882352941 0 0 setrgbcolor
46 u 10 u 48 u 40 u box fill
0.588235294117647 0 0 setrgbcolor
48 u 10 u 50 u 40 u box fill
0.611764705882353 0 0 setrgbcolor
50 u 10 u 52 u 40 u box fill
0.635294117647059 0 0 setrgbcolor
52 u 10 u 54 u 40 u box fill
0.658823529411765 0 0 setrgbcolor
54 u 10 u 56 u 40 u box fill
0.682352941176471 0 0 setrgbcolor
56 u 10 u 58 u 40 u box fill
0.705882352941177 0 0 setrgbcolor
58 u 10 u 60 u 40 u box fill
0.729411764705882 0 0 setrgbcolor
60 u 10 u 62 u 40 u box fill
0.752941176470588 0 0 setrgbcolor
62 u 10 u 64 u 40 u box fill
0.776470588235294 0 0 setrgbcolor
64 u 10 u 66 u 40 u box fill
0.8 0 0 setrgbcolor
66 u 10 u 68 u 40 u box fill
0.823529411764706 0 0 setrgbcolor
68 u 10 u 70 u 40 u box fill
0.847058823529412 0 0 setrgbcolor
70 u 10 u 72 u 40 u box fill
0.870588235294118 0 0 setrgbcolor
72 u 10 u 74 u 40 u box fill
0.894117647058824 0 0 setrgbcolor
74 u 10 u 76 u 40 u box fill
0.917647058823529 0 0 setrgbcolor
76 u 10 u 78 u 40 u box fill
newpath
40 u 30 u moveto
30 u 10 u lineto
60 u 0 u lineto stroke
0 1 0 setrgbcolor
newpath
0 u 100 u moveto
100 u 0 u lineto stroke
%%PageTrailer
pagelevel restore
showpage
];
}
