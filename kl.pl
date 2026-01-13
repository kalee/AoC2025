#!/usr/bin/perl

use v5.32;

my @map = map { chomp; [ split // ] } <>;
my $xmax = $#{ $map[0] };
my $ymax = $#map;

my ($sum, $imm, $op);

for my $x (0 .. $xmax) {
    if ($map[$ymax][$x] ne ' ') {
        $op = $map[$ymax][$x];
        $imm = $op eq '*';
    }
    my $expr = "\$imm $op= ";
    $expr .= $map[$_][$x] for 0 .. $ymax-1;
    if ($expr =~ /\d/) {
        eval $expr;
    } else {
        $sum += $imm;
    }
}
$sum += $imm;

say $sum;
