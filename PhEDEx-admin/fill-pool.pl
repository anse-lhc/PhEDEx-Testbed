#!/usr/bin/perl -w
#
# Populate a disk pool with hard-links to a specified file to fake the appearance
# of a huge amount of data on a small disk
#
use strict;
use Getopt::Long;
use POSIX;
use File::Path;

my ($help,$verbose,$debug,$file,$dir,$i,$j,$k,$numFiles,$perLevel,$len,$dst);
my ($result,$numDirs,$err,$symlink,$step,$total);

$help = $verbose = $debug = $err = $symlink = 0;
$numFiles = 10000;

GetOptions(
	    'dir=s'	=> \$dst,
	    'file=s'	=> \$file,
	    'num=i'	=> \$numFiles,
	    'help'	=> \$help,
	    'symlink'	=> \$symlink,
	    'debug'	=> \$debug,
	    'verbose'	=> \$verbose,
	  );

defined($dst) or die "Must specify --dir, the directory to populate\n";
-d $dst and die "Destination directory '$dst' already exists\n";
$dst .= '/' unless $dst =~ m%/$%;
defined($file) or die "Must specify --file, the source-file to link to\n";
-f $file or die "Source file '$file' does not exist\n";
$numFiles > 0 or die "Number of files (--num) must be positive\n";

# Sanity-check on number of files to create...
if ( $numFiles > 256**3 ) {
  die "Cannot create more than 256^3 files, sorry!\n(That's about 16 million files)\n";
}
if ( ! $symlink ) {
# There's a harder limit than that for hard links...
  die "Cannot create more than 32K files in one go (a filesystem limit)\n"
    if $numFiles > 32000;
}

$perLevel = 256;
$len      = 2;
print "Creating $numFiles files in $dst\n";
print "Using $perLevel files per directory\n";

$i = ceil( log($numFiles)/log(256) );
$i++ if $i%2;
$numDirs = ceil($numFiles/256);
$total = $numFiles;

$|=1;
while ( $numDirs > 0 ) {
  print "$numDirs directories to go...  \r" unless $numDirs %100;
  $dir = sprintf("%0${i}x",$numDirs);
  $dir = join('/',unpack("(A$len)*",$dir));
  $verbose && print 'Create directory ',$dir,"\n";
  $dir = $dst . $dir;
  mkpath([$dir]);
  for ($j = 255; $j>0; $j--) {
    $result = $dir . '/file-' . sprintf('%02x',$j) . '.dat';
    $debug && print "Link $file to $result\n";
    if ( $symlink ) {
      symlink $file,$result or die "\nCannot symlink $file to $result (",$total-$numFiles," links created)\n";
    } else {
      link $file,$result or die "\nCannot link $file to $result (",$total-$numFiles," links created)\n";
    }
  }
  $numDirs--;
  $numFiles--;
}
  print "                       \r";

print "All done\n";













