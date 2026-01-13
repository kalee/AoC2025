#!/usr/bin/perl
use strict;
use warnings;
no warnings 'uninitialized';
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
my %grid = ();

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



exit(0);

# Basic 2D Grid subroutines
#######################################
sub load_grid {
    @data=();
    load_data();

    my $col = 0;
    my $row = 0;
    #my %grid = ();
    for my $line (@data) {
        chomp $line;
        my @chars = split //, $line;        
        for my $col (0..$#chars) {
            $grid{"$row,$col"} = $chars[$col];
        }
        $row++;
    }
}

sub get_dimensions {
    my ($max_row, $max_col) = (0, 0);
    
    foreach my $key (keys %grid) {
        my ($row, $col) = split /,/, $key;
        $max_row = $row if $row > $max_row;
        $max_col = $col if $col > $max_col;
    }
    
    return ($max_row, $max_col);
}

# Access cell
sub get_cell {
    my ($row, $col) = @_;
    return $grid{"$row,$col"};
}

# Set cell
sub set_cell {
    my ($row, $col, $value) = @_;
    $grid{"$row,$col"} = $value;
}

# Print grid
sub print_grid {
    my ($max_row, $max_col) = get_dimensions();
    
    for my $r (0..$max_row) {
        for my $c (0..$max_col) {
            my $cell = get_cell($r, $c) // '.';
            print $cell;
        }
        print "\n";
    }
}
#######################################

sub part1 {
    
    load_grid();

    my ($rows, $cols) = get_dimensions();

    my $count = 0;
    for my $r (0..$rows) {
        for my $c (0..$cols) {
            my $cell = get_cell($r, $c) // '.';
            my $cell_count = 0;
            if ($cell eq '@') {
                $cell_count++ if (get_cell($r-1, $c-1) eq '@');
                $cell_count++ if (get_cell($r-1, $c) eq '@');
                $cell_count++ if (get_cell($r-1, $c+1) eq '@');
                $cell_count++ if (get_cell($r, $c-1) eq '@');
                $cell_count++ if (get_cell($r, $c+1) eq '@');
                $cell_count++ if (get_cell($r+1, $c-1) eq '@');
                $cell_count++ if (get_cell($r+1, $c) eq '@');
                $cell_count++ if (get_cell($r+1, $c+1) eq '@');
                $count++ if ($cell_count < 4);
            }
        }
    }

    print "part1: ", $count, "\n";
}

sub part2 {
    my ($rows, $cols) = get_dimensions();
    my $total = 0;
    my $count = 0;
    do {
        my %grid_remove = ();
        $count = 0;
        for my $r (0..$rows) {
            for my $c (0..$cols) {
                my $cell = get_cell($r, $c) // '.';
                my $cell_count = 0;
                if ($cell eq '@') {
                    $cell_count++ if (get_cell($r-1, $c-1) eq '@');
                    $cell_count++ if (get_cell($r-1, $c) eq '@');
                    $cell_count++ if (get_cell($r-1, $c+1) eq '@');
                    $cell_count++ if (get_cell($r, $c-1) eq '@');
                    $cell_count++ if (get_cell($r, $c+1) eq '@');
                    $cell_count++ if (get_cell($r+1, $c-1) eq '@');
                    $cell_count++ if (get_cell($r+1, $c) eq '@');
                    $cell_count++ if (get_cell($r+1, $c+1) eq '@');
                    if ($cell_count < 4) {
                        $grid_remove{"$r,$c"} = 1;
                        $count++;
                    }
                }
            }
        }
        foreach my $key (keys %grid_remove) {
            my ($row, $col) = split /,/, $key;
            set_cell($row, $col, '.');
        }

        $total += $count;
    } while ($count > 0);
    
    print "part2: ", $total, "\n";
}

sub load_data {
    ##### Load Data #####
    #my $filename = '../data/day4.txt';
    #open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
    #while (<$fh>) {
    while (<DATA>) {
        chomp;
        push @data,$_;
    }
    #close $fh;
}

__DATA__
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.