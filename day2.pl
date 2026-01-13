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

exit(0);


sub part1 {
    @data=();
    load_data();
    my $count = 0;
    for my $item (@data) {
        my ($first, $second) = map { 0 + $_ } $item =~ /^(.*)-(.*)$/;
        for my $i ($first..$second) {
            my $i_str = "$i";  # Convert to string
            while ($i_str =~ /^(\d+)\1$/g) {
                $count+=$i;
            }
        }
    }
    
    print "part1: ", $count, "\n";
}

sub part2 {
    @data=();
    seek DATA, $data_start, 0;  # reposition the filehandle right past __DATA__
    load_data();

    my $count = 0;
    for my $item (@data) {
        my ($first, $second) = map { 0 + $_ } $item =~ /^(.*)-(.*)$/;
        for my $i ($first..$second) {
            my $i_str = "$i";  # Convert to string
            while ($i_str =~ /^(\d+)\1+$/g) {
                $count+=$i;
            }
        }
    }

    print "part2: ", $count, "\n";
}

sub load_data {
    ##### Load Data #####
    #my $filename = '../data/day2.txt';
    #open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
    #while (<$fh>) {
    while (<DATA>) {
        chomp;
        @data = split /,/, $_;  # Split on comma
    }
    #close $fh;    
}

__DATA__
11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
