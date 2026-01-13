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
my @data1 = ();
my %grid = ();

load_data();

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
    my ($grid, $data) = @_;
    %grid = %{$grid};
    my @data = @{$data};


    my $col = 0;
    my $row = 0;
    for my $line_ref (@data) {
        my @line = @{$line_ref};
        my $line = join '', @line;

        chomp $line;
        #print "\$line: $line", "\n";
        my @chars = split //, $line;        
        for my $col (0..$#chars) {
            $grid{"$row,$col"} = $chars[$col];
            #print "$chars[$col]";
        }
        $row++;
        #print;
    }
    #print;
}

sub get_dimensions {
    my ($grid) = @_;
    %grid = %{$grid};
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
    my ($grid, $row, $col) = @_;
    %grid = %{$grid};

    return $grid{"$row,$col"};
}

# Set cell
sub set_cell {
    my ($grid, $row, $col, $value) = @_;
    %grid = %{$grid};

    $grid{"$row,$col"} = $value;
}

# Print grid
sub print_grid {
    my ($grid) = @_;
    %grid = %{$grid};

    my ($max_row, $max_col) = get_dimensions(\%grid);
    
    for my $r (0..$max_row) {
        for my $c (0..$max_col) {
            my $cell = get_cell($grid, $r, $c) // '.';
            print $cell;
        }
        print "\n";
    }
}

# Rotate Grid counter-clockwise
sub rotate_grid_ccw {
    my ($grid_ref) = @_;
    
    # Find max row and col from the original grid
    my $max_row = 0;
    my $max_col = 0;
    
    foreach my $key (keys %{$grid_ref}) {
        my ($row, $col) = split /,/, $key;
        $max_row = $row if $row > $max_row;
        $max_col = $col if $col > $max_col;
    }
    
    # Create new hash for rotated grid
    my %rotated;
    
    # Rotate counter-clockwise
    # Original grid[row][col] -> Rotated grid[max_col - col][row]
    foreach my $key (keys %{$grid_ref}) {
        my ($row, $col) = split /,/, $key;
        my $new_row = $max_col - $col;
        my $new_col = $row;
        $rotated{"$new_row,$new_col"} = $grid_ref->{$key};
    }
    
    return \%rotated;
}


# Rotate Grid Counter-clockwise in-place
sub rotate_grid_ccw_inplace {
    my ($grid_ref) = @_;
    
    # Find max row and col from the original grid
    my $max_row = 0;
    my $max_col = 0;
    
    foreach my $key (keys %{$grid_ref}) {
        my ($row, $col) = split /,/, $key;
        $max_row = $row if $row > $max_row;
        $max_col = $col if $col > $max_col;
    }
    
    # Store all transformations first (to avoid conflicts)
    my %temp_mappings;
    
    foreach my $key (keys %{$grid_ref}) {
        my ($row, $col) = split /,/, $key;
        my $new_row = $max_col - $col;
        my $new_col = $row;
        my $new_key = "$new_row,$new_col";
        
        $temp_mappings{$new_key} = $grid_ref->{$key};
    }
    
    # Clear the original hash
    %{$grid_ref} = ();
    
    # Copy the rotated values back
    %{$grid_ref} = %temp_mappings;
}
#######################################



sub part1 {

    

    # Pop the last line (array reference) and dereference
    my @operations = @{pop @data};

    # Print all values
    #print "@operations\n";

    ## Or print each element individually
    #foreach my $value (@operations) {
    #    print "$value\n";
    #}    

    my @result = ();
    for my $i (0..$#operations) {
        if ($operations[$i] eq '*') {
            $result[$i] = 1;
        } else {
            $result[$i] = 0;
        }
    }

    foreach my $line_ref (@data) {
        my @line = @$line_ref;  # Dereference
        for my $i (0..$#line) {
            if ($operations[$i] eq '*') {
                $result[$i] *= $line[$i];
            } else {
                $result[$i] += $line[$i];
            }
        }        
    }

    my $result = 0;
    for my $i (0..$#operations) {
        $result += $result[$i];
    }
    print "part1: ", $result, "\n";
}

sub part2 {
    my $total = 0;
    my @temp = ();
    my $temp;
    my @string = ();
    my $string;

    load_grid(\%grid, \@data1);
    #print_grid(\%grid);

    rotate_grid_ccw_inplace(\%grid);
    #print_grid(\%grid);

    # Find max row and col from the original grid

    my ($max_row, $max_col) = get_dimensions(\%grid);
    
    for my $r (0..$max_row) {
        for my $c (0..$max_col) {
            my $cell = get_cell(\%grid, $r, $c) // ' ';
            push @string, $cell;
        }
        $string = join '', @string;    
        my ($val, $op) = $string =~ /^\s*(\d+)\s*([\*\+]?)\s*$/;
        
        if ($op =~ /[\*\+]/) {
            if ($val > 0) {
                push @temp, $val;
            }
            if ($op eq '*') {
                $temp = 1;
                for my $i (@temp) {
                    #print "\$i:$i ", " ";
                    $temp *= $i;
                }
                #print "\$string:$string ", "\$val:$val ", "\$op:$op ", "\$temp:$temp ", "\@temp: @temp ", "\n";
            } else {
                $temp = 0;
                for my $i (@temp) {
                    #print "\$i:$i ", " ";
                    $temp += $i;
                }
                #print "\$string:$string ", "\$val:$val ", "\$op:$op ", "\$temp:$temp ", "\@temp: @temp ", "\n";
            }
            $total += $temp;
            @temp = ();
            @string = ();

        } else {
            if ($val > 0) {
                push @temp, $val;
            }
        }
        @string = ();
    }
 
    print "part2: ", $total, "\n";
}

sub load_data {
    ##### Load Data #####
    my $filename = '../data/day6.txt';
    open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
    while (<$fh>) {
    #while (<DATA>) {
        chomp;
        push @data, [split ' '];
        push @data1, [split ''];
        #push @data, [split ' '];  # Anonymous array reference
        #push @data, [split / +/];
    }
    close $fh;
}

__DATA__
123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  
