#!/usr/bin/env perl
use warnings;
use strict;

my ($stage, $pfn) = @ARGV;

if ($stage eq 'pre') {
    print "pre-deletion test:   pfn=$pfn\n";
} elsif ($stage eq 'post') {
    print "post-deletion test:  pfn=$pfn\n";
} else {
    print "unknown stage=$stage!\n";
}

exit(0);
