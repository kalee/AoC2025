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
    
    print "part1: ","\n";
}

sub part2 {
    @data=();
    seek DATA, $data_start, 0;  # reposition the filehandle right past __DATA__
    load_data();
    
    print "part2: ","\n";
}

sub load_data {
    ##### Load Data #####
    #my $filename = '../data/day4.txt';
    #my $filename = '../data/google-0.txt';
    #my $filename = '../data/reddit-.txt';
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