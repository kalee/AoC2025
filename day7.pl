#!/usr/bin/perl
use strict;
use warnings;
no warnings 'uninitialized';
require './GridGraphLib.pl';  # Load the library

use Time::HiRes qw/gettimeofday tv_interval time/;
use Data::Dumper;
use constant FALSE => 0;
use constant TRUE => 1;
use constant DEBUG => 0;

my $start_time = [gettimeofday];
my $data_start = tell DATA;
my $start = 0;
my $end = 0;
my $runtime = 0;
my @data = ();

$start = time();
part1();
$end = time();
$runtime = sprintf("%.8s", ($end - $start)*1000);
print "part1 took $runtime ms\n";

$start = time();
part2();
$end = time();
$runtime = sprintf("%.8s", ($end - $start)*1000);
print "part2 took $runtime ms\n";


my $elapsed = tv_interval ( $start_time, [gettimeofday]);
print "Total Elapsed Time: ", $elapsed, "\n";

exit(0);


sub part1 {
    @data=();
    load_data();

    # Create and populate a grid
    my ($grid, $meta) = new_grid();
    populate_from_lines($grid, $meta, \@data);

    my $part1 = 0;
    my @arr = (0) x $meta->{max_col};

    # We know that S is only in one location.  Get that location.
    my @found = find_cells($grid, 'S');
    my ($r, $c) = map { 0 + $_ } @{$found[0]};
    $arr[$c] = 1;


    @found = find_cells($grid, '^');
    # Sort in reading order (row ascending, then column ascending)
    @found = sort { 
        $a->[0] <=> $b->[0]  # Top to bottom (row)
        || 
        $a->[1] <=> $b->[1]  # Left to right (column)
    } @found;

    for my $cell_ref (@found) {
        ($r, $c) = map { 0 + $_ } @{$cell_ref};
        if ($arr[$c] == 1) {
            $arr[$c] = 0;
            $part1++; 
            
            my $c1 = $c-1;
            $arr[$c1] = 1;
            
            $c1 = $c+1;
            $arr[$c1] = 1;
        }
    }

    print "part1: ", $part1, "\n";
}

sub part2 {
    # Create and populate a grid
    my ($grid, $meta) = new_grid();
    populate_from_lines($grid, $meta, \@data);

    my $part2 = 0;
    my @arr = (0) x $meta->{max_col};

    # We know that S is only in one location.  Get that location.
    my @found = find_cells($grid, 'S');
    my ($r, $c) = map { 0 + $_ } @{$found[0]};
    $arr[$c] = 1;


    @found = find_cells($grid, '^');
    # Sort in reading order (row ascending, then column ascending)
    @found = sort { 
        $a->[0] <=> $b->[0]  # Top to bottom (row)
        || 
        $a->[1] <=> $b->[1]  # Left to right (column)
    } @found;

    for my $cell_ref (@found) {
        ($r, $c) = map { 0 + $_ } @{$cell_ref};
        if ($arr[$c] > 0) {            
            my $c1 = $c-1;
            $arr[$c1] += $arr[$c];
            
            $c1 = $c+1;
            $arr[$c1] += $arr[$c];

            $arr[$c] = 0;
        }
    }

    for my $val (@arr) {
        $part2 += $val;
    }

    print "part2: ", $part2, "\n";
}

sub load_data {
    ##### Load Data #####
    #my $filename = '../data/day7.txt';
    #open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
    #while (<$fh>) {
    while (<DATA>) {
        chomp;
        push @data,$_;
    }
    #close $fh;
}

__DATA__
.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............