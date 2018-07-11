#!/usr/bin/perl
use warnings;

#################################################################################
# Version 0.1
# Author : Priyadarshee D. Kumar
# Date : 24/12/2012
# Purpose : To check the staus of license server and number of license pulled
# Usage : It takes the port number and the license server hostname as argument
#     It checks whether the license server is running on the given
# 	  port@host and it also checks how many licenses are pulled from
# 	  the remote license server by greping the local server hostname
# 	  Here Replace the $lmpath with the path to lmutil
# 	       Replace the $serv with the local prod server hostname from where
# 	       license is pulled
################################################################################### 	  


$#ARGV += 1;
unless ($#ARGV == 2){
	print "$0 requires 2 arguments\n";
	print "$0 [port] [licserverhostname]\n";
	exit 99;
	}

my $serv = "plmdvp01";
my $lmpath = "/flexlm/lmutil";
my $port = "$ARGV[0]";
my $host = "$ARGV[1]";
my $licsrv = $port.'@'.$host;
#print "$licsrv\n";

my $users =`$lmpath lmstat -c $licsrv -a | grep -i $serv | wc -l`;

chomp($users);
system "$lmpath lmstat -c $licsrv -a > /dev/null";
if ($? == 0){
	print "LIC. OK : License is running on $licsrv and pulling $users lics now.\n";
	exit 0;
	}
if ($? != 0){
	print "CRITICAL : License server is down or not pulling licenses.\n";
	exit 2;
	}
	


#print "$users\n";
