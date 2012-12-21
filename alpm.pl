#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  alpm.pl
#
#        USAGE:  ./alpm.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  YOUR NAME (), 
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  12/20/2012 08:48:07 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;
require ALPM;
require Tie::Hash;
print Dumper(\@INC);
# It's easier just to load a configuration file:
use ALPM qw(/etc/pacman.conf);
 
# My new favorite way to get/set options.  A tied hash.  (TMTOWTDI)
my %alpm;
tie %alpm, "ALPM";
$alpm{root} = '/';
printf "Root Dir = %s\n", $alpm{root};
my ($root, $dbpath, $cachedir) = @alpm{qw/root dbpath cachedir/};
 
# Callback options...
$alpm{logcb} = sub { my ($lvl, $msg) = @_; print "[$lvl] $msg\n" };
 
# Querying databases & packages
my $localdb = ALPM->localdb;
my $pkg     = $localdb->find('perl');
 
# Lots of different ways to get package attributes...
my $attribs_ref    = $pkg->attribs_ref;
my $name           = $pkg->name;
my ($size, $isize) = $pkg->attribs('size', 'isize');
print "$name $attribs_ref->{version} $attribs_ref->{arch} $size/$isize";

