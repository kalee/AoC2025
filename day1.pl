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
#END { print "Duration: ", tv_interval()*1000, " ms\n"; }

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



sub times_around {
    my ($start_hour, $adjustment, $target_hour) = @_;
    
    die "Invalid hour: must be 0-99" 
        unless ($start_hour >= 0 && $start_hour <= 99 && 
                $target_hour >= 0 && $target_hour <= 99);
    
    my $final_hour = (($start_hour + $adjustment) % 100 + 100) % 100;
    return ($final_hour, 0) if $adjustment == 0;
    
    my $distance_to_target;
    if ($adjustment > 0) {
        $distance_to_target = ($target_hour - $start_hour + 100) % 100;
        $distance_to_target = 100 if $distance_to_target == 0;
    } else {
        $distance_to_target = ($start_hour - $target_hour + 100) % 100;
        $distance_to_target = 100 if $distance_to_target == 0;
    }
    
    my $abs_adj = abs($adjustment);
    my $times = ($abs_adj >= $distance_to_target) 
                ? 1 + int(($abs_adj - $distance_to_target) / 100)
                : 0;
    
    #print "\$start_hour: $start_hour", " ", "\$adjustment: $adjustment", " ", "\$target_hour: $target_hour", " ", "\$times: $times", "\n";
    #$times++ if $final_hour == $target_hour;
    
    return ($final_hour, $times);
}


sub times_on {
    my ($start_hour, $adjustment, $target_hour) = @_;
    
    die "Invalid hour: must be 0-99" 
        unless ($start_hour >= 0 && $start_hour <= 99 && 
                $target_hour >= 0 && $target_hour <= 99);
    
    my $final_hour = (($start_hour + $adjustment) % 100 + 100) % 100;
    return ($final_hour, 0) if $adjustment == 0;
    
    my $times = 0;    
    $times++ if $final_hour == $target_hour;
    
    return ($final_hour, $times);
}



sub part1 {
    @data=();
    load_data();

    my $value = 50;
    my $counter = 0;
    for my $val (@data) {
        my ($first_char, $number) = $val =~ /^(.)(.*)$/;
        if ($first_char eq 'L') {
            $number *= -1;
        }
        my ($final, $times) = times_on($value, $number, 0);
        $value = $final;
        $counter += $times;
    }  
    #print Dumper($counter), "\n";
    print "part1: ", $counter, "\n";
}

sub part2 {
    @data=();
    seek DATA, $data_start, 0;  # reposition the filehandle right past __DATA__
    load_data();

    my $value = 50;
    my $counter = 0;
    for my $val (@data) {
        my ($first_char, $number) = $val =~ /^(.)(.*)$/;
        if ($first_char eq 'L') {
            $number *= -1;
        }
        my ($final, $times) = times_around($value, $number, 0);

        #print "\$times: $times" , " ", "\$counter: $counter", "\n";

        $value = $final;
        $counter += $times;
    }      
    print "part2: ", $counter, "\n";
}

sub load_data {
    ##### Load Data #####
    my $filename = '../data/day1.txt';
    #my $filename = '../data/google-0.txt';
    #my $filename = '../data/reddit-.txt';
    open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
    while (<$fh>) {
    #while (<DATA>) {
        chomp;
        push @data,$_;
    }
}

__DATA__
L68
L30
R48
L5
R60
L55
L1
L99
R14
L82