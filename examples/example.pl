#!/usr/bin/perl

use PostScript::Simple;

$t = new PostScript::Simple(landscape => 0,
#            xsize => 100,
#            ysize => 100,
            eps => 0,
            papersize => "a4",
            colour => 1,
            clip => 0,
            units => "mm");

$t->newpage(-1);

$t->line(10,10, 10,50);
$t->setlinewidth(8);
$t->line(90,10, 90,50);
$t->linextend(40,90);
$t->setcolour("brightred");
$t->circle(40, 90, 30, 1);
$t->setcolour("darkgreen");
$t->setlinewidth(0.1);
for ($i=0; $i<360; $i+=20)
{
  $t->polygon("offset=0,0 rotate=$i,70,90 filled=0", 40,90, 69,92, 75,84);#, 70,88, 40,90);
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

$s = new PostScript::Simple(xsize => 50,
            ysize => 200);

$s->newpage;
$s->box(10, 10, 40, 190);

$o = 10;
for ($i=12; $i<80; $i+=2)
{
  $t->setcolour($i*3, 0, 0);
  $t->box($o, 10, $i, 40, 1);
  $o = $i;
}

$t->line((40, 30), (30, 10));
$t->linextend(60, 0);

$t->line((0, 100), (100, 0),(0, 255, 0));

#$t->display();

$t->output("test-a.ps");
$s->output("test-b.ps");


  
        # create a new PostScript object
        $p = new PostScript::Simple(papersize => "a4",
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
        $p->output("test-c.ps");
  
