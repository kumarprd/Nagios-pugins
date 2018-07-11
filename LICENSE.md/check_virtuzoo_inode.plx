#!/usr/bin/perl
use warnings;
########################################################################
# 
# Version : 0.1 
# Date : 21/11/2012
# 
# Purpose : Nagios plugin to monitor the Virtuzoo container Inode limit 
#
# Usage : It takes 2 arguments, Warning ånd Critical in percentage, If the
#     inode usage  in the container crosses the warning limit it will 
# 	  show WARN and if crosses Critical limit show CRIT with Redcolour
# 	   
##########################################################################


my $REQPARAM = 2;
my $exit;
my $Iwarn = sprintf("%.3f",$ARGV[0]);
my $Icrit = sprintf("%.3f",$ARGV[1]); 

$#ARGV +=1;
unless ($#ARGV == $REQPARAM){
	system "clear";
	print "$0 requires $REQPARAM arguments\n";
	print "Usage : $0 [Warn] [Crit]\n";
	exit 100;
	}

if ( $Iwarn == $Icrit || $Iwarn > $Icrit ){
	print "UNKNOWN: [warn] must be less than [crit]\n";
	exit 100;
	}

my $file = "/proc/vz/vzquota";
open (FILE,"$file") || die "Error : $!";
while (<FILE>){
	if (/(\d+):.*/){ $id = $1; }
		if (/\s+([a-z]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/){
		        my $Iusage = $2;
			my $Isoftlimit = $3;
			my $Ihardlimit = $4;
			my $time = $5;
			my $expire = $6;
			my $name = `vzlist -1 $id -o name`;
			chomp $name;
			$name =~ s/\s+//;
			$name =~ s/-/SERVICE-CONTAINER/; 
		        my $Iusagep = sprintf("%.3f",100*($Iusage/$Isoftlimit));
				
			if ( $Iusagep < $Iwarn && $Iusagep < $Icrit ){
#				$exit = 0;
				print "OK: $name has used only $Iusagep% inode\n";
				next;
			}
			if ( $Iusagep >= $Iwarn && $Iusagep < $Icrit ){
				$exit = 1;
				print "WARN: $name  has exceeded warning limit and used $Iusagep% inodes\n";
				next;
			}
			if ( $Iusagep >= $Icrit ) {
				$exit = 2;
				print "CRIT: $name  has exceeded critical limit and used $Iusagep% inodes\n";
				next;
			}
		}

}

exit($exit);
	
