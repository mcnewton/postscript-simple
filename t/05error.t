#!/usr/bin/perl
use strict;
use lib qw(./lib ../lib t/lib);
use Test::Simple tests => 12;
use PostScript::Simple;

# test for errors

my $s = new PostScript::Simple(papersize => "Letter");

ok( ! defined($s->err()) );

ok( $s->setcolour("yellow") );

ok( ! defined $s->err() );

ok( ! $s->setcolour("yellowandPINK") );

ok( defined $s->err() );

ok( $s->err() eq "bad colour name 'yellowandpink'" );

ok( ! $s->linextend(4) );

ok( $s->err() eq "wrong number of args for linextend" );

ok( ! $s->newpage("test") );

ok( $s->err() eq "Do not use newpage for eps files!" );

ok( $s->line(0, 0,  100, 100) );

ok( $s->err() eq "Do not use newpage for eps files!" );


