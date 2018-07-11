use warnings;

############################################################################
# Version : 0.1
# Author : P. D. Kumar 
# Date : 25/12/2012
# Purpose : To check status of a Oracle db 
# Usage : It takes the Oracle SID as argument and use tnsping utility
#
#
##########################################################################



$#ARGV += 1;

if ($#ARGV != 1){
  print "$0 requires a valid ORACLE SID name as argument,consult your DBA.\n";
	print "Usage : $0 [ORACLESID]\n";
	exit 99;
	}



foreach (@ARGV){
		system "tnsping $_  > /dev/null";
		my $exit = $?;
			if ($exit == 0){
			print "DB OK : PLM DB - $_ is up and running.\n";
			exit 0;
			}
			if ($exit != 0){
			print "Cricitical : PLM DB - $_ is down.\n";	
			exit 2;
		        }	
}
