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


#print Dumper(@data), "\n";

exit(0);


sub find_largest_k_digits {
    my ($sequence, $k) = @_;
    my @digits = split //, $sequence;
    my $n = scalar @digits;
    
    return "" if $n < $k;  # Not enough digits
    
    my $result = "";
    my $start = 0;
    
    for my $pos (0..$k-1) {
        my $remaining_needed = $k - $pos - 1;
        my $search_end = $n - $remaining_needed - 1;
        
        my $max_digit = '0';
        my $max_index = $start;
        
        for my $i ($start..$search_end) {
            if ($digits[$i] gt $max_digit) {
                $max_digit = $digits[$i];
                $max_index = $i;
                last if $max_digit eq '9';
            }
        }
        
        $result .= $max_digit;
        $start = $max_index + 1;
    }
    
    return $result;
}


sub part1 {
    @data=();
    load_data();

    my $sum = 0;
    for my $num_str (@data) {
        my @all_digits = $num_str =~ /(.)/g;
        # Step 1: Extract all digits except the last one using regex
        my @digits_not_last = $num_str =~ /(\d)(?=.*\d)/g;
        #print Dumper(@digits_not_last, $num_str), "\n";

        # Step 2: Find the largest digit (excluding last)
        my $largest_not_last = (sort { $b <=> $a } @digits_not_last)[0];
        #print "Largest digit (not last): $largest_not_last\n";

        my $index = -1;
        for my $i (0..$#all_digits) {
            if ($all_digits[$i] == $largest_not_last) {
                $index = $i;
                last;
            }
        }

        # Step 3: Slice remaining items
        my @temp = @all_digits[$index+1 .. $#all_digits];


        # Step 4: Sort (descending)
        my @sorted = sort { $b <=> $a } @temp;

        # Step 5: Get max in sorted remaining to get second largest value
        my $second_largest = $sorted[0];

        
        my $val = 0 + ($largest_not_last . $second_largest); 
        $sum  += $val;
        #print $val, "\n";

    }

    print "part1: ", $sum, "\n";
}

sub part2 {
    @data=();
    seek DATA, $data_start, 0;  # reposition the filehandle right past __DATA__
    load_data();

    my $total = 0;
    my $count = 0;

    for (@data) {
        chomp;
        next if /^\s*$/;
        
        my $joltage = find_largest_k_digits($_, 12);
        $total += $joltage;
        $count++;
    }    
    print "part2: ", $total, "\n";
}

sub load_data {
    ##### Load Data #####
    my $filename = '../data/day3.txt';
    open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
    while (<$fh>) {
    #while (<DATA>) {
        chomp;
        push @data, $_;
    }
    close $fh;
}

__DATA__
987654321111111
811111111111119
234234234234278
818181911112111
