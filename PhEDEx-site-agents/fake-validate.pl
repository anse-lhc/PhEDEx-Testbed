#!/usr/bin/env perl

# Randomly tests each of the possible validation outcomes

use warnings;
use strict;

my ($status, $pfn, $size, $checksum) = @ARGV;

# Parse pfn to get dataset/block/file names as defined in Lifecycle.pm  
my @fields = reverse (split "/", $pfn);
my $filename = shift @fields;
print  "file: $filename\n";
($filename =~ /-stuckfile$/) && print "Matches STUCK file\n";

if ($status eq 'pre') {
  print "fake validation success\n";
} else {
  print "post-validation success\n";
}
exit(0);
