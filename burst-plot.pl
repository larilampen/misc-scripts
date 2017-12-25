#!/usr/bin/perl

# This is a very simple helper script for running a Burstcoin plotter
# on similar servers in a (possibly large) server room / farm.

# We assume the hostnames contain a numbering (e.g. srv001, ..., srv666)
# and that each server has the same amount of disk space to be allocated
# for plot files. All this script does is ensure the plots do not overlap.

# Usage:
# perl burst-plot.pl [[first chunk] chunks]

# Running without parameters creates a huge plot in a single file. Specifying
# a number creates that many separate files ("chunks"). Specifying two numbers
# does the same but starts at the specified chunk (numbering starts from 1)
# rather than the first one.

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

my $chunks = 1;
my $firstchunk = 0;
if ($#ARGV>=1) {
	$firstchunk = int($ARGV[0])-1;
	$chunks = int($ARGV[1]);
} elsif ($#ARGV>=0) {
	$chunks = int($ARGV[0]);
}

my $hostnum;
if (`hostname` =~ /([1-9]\d*)/) {
	$hostnum = $1;
} else {
	die "Hostnames are not numbered";
}
my $nonces = int($tb * 4 * 1024**2);
my $startplot = ($hostnum - 1) * ($nonces + 1);

make_path($plotdir) unless -f $plotdir;

if ($chunks > 1) {
	my $nonces_per_chunk = int($nonces/$chunks);
	for (my $i=$firstchunk; $i<$chunks; $i++) {
		my $startchunk = $startplot+$i*$nonces_per_chunk;
		# adjust size of last chunk so that there is no rounding error
		my $nonces_this_chunk = ($i == $chunks-1) ? ($nonces-$startchunk) : $nonces_per_chunk;
		my $cmd = "nice $bin -k $key -x 1 -d $plotdir -s $startchunk -n $nonces_this_chunk -t $threads";
		print "Plotting chunk ",$i+1,"/$chunks: $cmd\n";
		system($cmd);
	}
} else {
	my $cmd = "nice $bin -k $key -x 1 -d $plotdir -s $startplot -n $nonces -t $threads";
	print "Plotting single file: $cmd\n";
	system($cmd);
}
