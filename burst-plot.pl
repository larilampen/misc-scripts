#!/usr/bin/perl

# This is a very simple helper script for running a Burstcoin plotter
# on similar servers in a (possibly large) server room / farm.

# We assume the hostnames contain a numbering (e.g. srv001, ..., srv666)
# and that each server has the same amount of disk space to be allocated
# for plot files. All this script does is ensure the plots do not overlap.

# Lari Lampen, 2017

use strict;
use File::Path qw(make_path);

# EDIT THESE PARAMETERS:

# Burstcoin account (numeric).
my $key = defined($ENV{'BURST_ID'}) ? $ENV{'BURST_ID'} : '1111111111111111111';
# Space to use, in TERABYTES per server.
my $tb = 1.6;
# Directory where plots are stored.
my $plotdir = $ENV{'HOME'} . "/burst/plots";
# Plotter binary, currently just mdcct.
my $bin = $ENV{'HOME'} . "/git/mdcct/plotavx2";
# Number of threads to use.
my $threads = `nproc` - 1;


my $hostnum;
if (`hostname` =~ /([1-9]\d*)/) {
	$hostnum = $1;
} else {
	die "Hostnames are not numbered";
}
my $nonces = int($tb * 4 * 1024**2);
my $startplot = ($hostnum - 1) * ($nonces + 1);

my $cmd = "nice $bin -k $key -x 1 -d $plotdir -s $startplot -n $nonces -t $threads";

make_path($plotdir) unless -f $plotdir;

print $cmd,"\n";

system($cmd);
