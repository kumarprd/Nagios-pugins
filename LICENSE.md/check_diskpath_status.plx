#!/usr/bin/perl
use warnings;
use strict;

#########################################################################################
# Version : 0.2
# Author : Priyadarshee D. Kumar
# Date : 25/12/2012
# Purpose : To check the used disk space and used inode limit using df on path or mountpoint.
#	    It takes the mountpoint/path as the second argument.
# Usage : It accepts 3 arguments, warnings limit and critical limit
#         If used %age is more than -w value it will give warning message
#         If used %age is more that -c value it will give critical message
#
# Syntax : check_disk.plx [PathToCheck] -w [WarnLimit] -c [CritLimit]
#
# Reason for this : In some cases (e.g. virtuzoo container in my case),
#               the default check_disk plugin comes with nagios doesnt work
# 	            The df,mount,procfs dont show properly mounted
# 	            device,filesystems,sizes. So I have to use df <path>/mountpoint
#		    to get the details which is fed into this plugin to get values.
#
# 	            It also works on all unix/linux systems also.
#########################################################################################
$#ARGV += 1;
unless ($#ARGV == 5){
	print "$0 requires minimum 3 arguments.\n";
	print "Syntax:\n";
	print "$0 [PathToCheck] -w [WarnLimit] -c [CritLimit]\n";
	exit 99;
	}
my $path = $ARGV[0];
my $warn = sprintf("%.2f",$ARGV[2]);
my $crit = sprintf("%.2f",$ARGV[4]);

chomp($path,$warn,$crit);
if ($warn >= $crit){
  print "Warn value should be less that Crit limit.\n";
	exit 99;
	}

#system "df -kh $path\n";


my ($DPused, $Dfree) = disk();
my ($IPused, $Ifree) = inode();

my $Dpused = sprintf("%.2f",$DPused);
my $Ipused = sprintf("%.2f",$IPused);



#print "$Dused\n";
#print "$Iused\n";
#print "$warn\n";
#print "$crit\n";

if ($Dpused < $warn && $Dpused < $crit && $Ipused < $warn && $Ipused < $crit){
	print "OK : Used Disk Space - $Dpused%(Free - $Dfree) Used Inode - $Ipused%(Free - $Ifree).\n";
	exit 0;
	}

if (($Dpused >= $warn && $Dpused < $crit) || ($Ipused >= $warn && $Ipused < $crit)){
	print "WARNING : Used Disk Space - $Dpused%(Free - $Dfree) Used Inode - $Ipused%(Free - $Ifree).\n";
	exit 1;
	}

if ($Dpused >= $crit || $Ipused >= $crit){
	print "CRITICAL : Used Disk Space - $Dpused%(Free - $Dfree) Used Inode - $Ipused%(Free - $Ifree).\n";
	exit 2;
	}



sub disk{
open (FH, "df -kh $path | sed 1d | tr -s '\n' ' ' |") || die "Unable to run df on $path : $!\n";
while (<FH>){
       		if (/(\S+)\s+(\d+.*\d*[A-Z])\s+(\d+.*\d*[A-Z])\s+(\d+.*\d*[A-Z])\s+(\d+.*\d*)%\s+(.*)/){
		my $Device = $1;
		my $DSize = $2;
		my $DUsed = $3;
		my $DAvail = $4;
		my $DPUsed = $5;
		my $MPoint = $6;
		chomp($Device,$DSize,$DUsed,$DAvail,$DPUsed,$MPoint);
#		print "\n$Device\n$DSize\n$DUsed\n$DAvail\n$DPUsed\n$MPoint\n";
                return ("$DPUsed","$DAvail");
		next;
		}
    }
}


sub inode{
open (FH1, "df -ih $path | sed 1d | tr -s '\n' ' ' |") || die "Unable to run df on $path : $!\n";
while (<FH1>){
       		if (/(\S)\s+(\d+.*\d*[A-Z])\s+(\d+.*\d*[A-Z])\s+(\d+.*\d*[A-Z])\s+(\d+.*\d*)%\s+(.*)/){
                my $Device = $1;
               	my $ISize = $2;
               	my $IUsed = $3;
               	my $IAvail = $4;
               	my $IPUsed = $5;
               	my $MPoint = $6;
               	chomp($ISize,$IUsed,$IAvail,$IPUsed,$MPoint);
#              	print "\n$Device\n$ISize\n$IUsed\n$IAvail\n$IPUsed\n$MPoint\n";
		return ("$IPUsed","$IAvail");
		next;
		}
    }
}
