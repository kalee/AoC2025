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
my %food = ();

@data=();
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



sub part1 {    
    my $fresh_count = 0;
    for my $item (@data) {
        $fresh_count++ if (exists $food{$item});
    }

    print "part1: ", $fresh_count, "\n";
}

sub part2 {
    my $num_keys = scalar keys %food;

    print "part2: ", $num_keys, "\n";
}


sub load_data {
    ##### Load Data #####
    #my $filename = '../data/day5.txt';
    #open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
    #while (<$fh>) {
    while (<DATA>) {
        chomp;
        if (/^(\d*)-(\d*)$/) {
            for my $i ($1 .. $2) {
                $food{$i} = "F"
            }
        } elsif (/^(\d+)$/) {
            push @data, $1;    
        }
    }
    #close $fh;
}

__DATA__
3-5
10-14
16-20
12-18

1
5
8
11
17
32
