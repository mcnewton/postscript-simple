#! /usr/bin/perl -w

# Examples for PostScript::Simple module
# Matthew Newton
# 09 November 2003

use strict;
use lib qw(../lib);
use PostScript::Simple 0.06;

my $ps;
my $eps;
my $y;

# First, create an EPS file for use later

$ps = new PostScript::Simple(xsize => 100,
                                ysize => 100,
                                colour => 1,
                                eps => 1,
                                reencode => undef);

$ps->setlinewidth(5);
$ps->box(10, 10, 90, 90);
$ps->setlinewidth("thin");
$ps->line(0, 50, 100, 50);
$ps->line(50, 0, 50, 100);
$ps->line(0, 40, 0, 60);
$ps->line(100, 40, 100, 60);
$ps->line(40, 0, 60, 0);
$ps->line(40, 100, 60, 100);
$ps->output("demo-square.eps");
undef $ps;

# Now generate the demo document. Start by creating the A4 document.
$ps = new PostScript::Simple(papersize => "a4",
                             units => "mm",
                             colour => 1,
                             eps => 0,
                             reencode => undef);

# Create a page 
mynewpage($ps, "EPS import functions");
$ps->setfont("Courier", 10);

$ps->setcolour("red");
$ps->box(20, 210, 45, 260);
$ps->importepsfile("demo-square.eps", 20, 210, 45, 260);
$ps->setcolour("darkred");
$ps->text({rotate => -90}, 14, 270, '$ps->importepsfile("demo-square.eps", 20, 210, 45, 260);');

$ps->setcolour("green");
$ps->box(80, 210, 105, 260);
$ps->importepsfile({stretch => 1}, "demo-square.eps", 80, 210, 105, 260);
$ps->setcolour("darkgreen");
$ps->text({rotate => -90}, 74, 270, '$ps->importepsfile({stretch => 1}, "demo-square.eps", 80, 210, 105, 260);');

$ps->setcolour("blue");
$ps->box(140, 210, 165, 260);
$ps->importepsfile({overlap => 1}, "demo-square.eps", 140, 210, 165, 260);
$ps->setcolour("darkblue");
$ps->text({rotate => -90}, 134, 270, '$ps->importepsfile({overlap => 1}, "demo-square.eps", 140, 210, 165, 260);');

$ps->setcolour(200, 0, 200);
$ps->box(30, 30, 90, 90);

$eps = new PostScript::Simple::EPS(file => "demo-square.eps", clip => 1);
$eps->scale(60/100);
$eps->translate(50, 50);
$eps->rotate(20);
$eps->translate(-50, -50);
$ps->importeps($eps, 30, 30);
$ps->setfont("Courier", 10);
$y = 90;
$ps->text(100, $y-=5, '$eps = new PostScript::Simple::EPS');
$ps->text(110, $y-=5, '(file => "demo-square.eps");');
$ps->text(100, $y-=5, '$eps->scale(60/100);');
$ps->text(100, $y-=5, '$eps->translate(50, 50);');
$ps->text(100, $y-=5, '$eps->rotate(20);');
$ps->text(100, $y-=5, '$eps->translate(-50, -50);');
$ps->text(100, $y-=5, '$ps->importeps($eps, 30, 30);');


# Write out the document.
$ps->output("demo.ps");
                

sub mynewpage
{
  my $ps = shift;
  my $title = shift;

  $ps->newpage;
  $ps->box(10, 10, 200, 287);
  $ps->line(10, 277, 200, 277);
  $ps->setfont("Times-Roman", 14);
  $ps->text(15, 280, "PostScript::Simple example file: $title");
}

