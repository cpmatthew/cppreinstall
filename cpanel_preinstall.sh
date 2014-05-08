#!/bin/bash

if [ ! -e /usr/bin/perl ] ; then
	yum install -y perl
fi	

echo "Rerun this with perl -x"
exit
	
#!/usr/bin/perl

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Getopt::Long;

my $run = 1;
my $fix = 0;

GetOptions ( 'fix|f' => sub{ $fix = 1 }, );

while ( $run ) {

	menu( $fix );

}

sub menu {
	my $fix = shift;

	if ( $fix == 1 ) {

		print "\nWhich would you like to do?\n";
		print "\t1) Fix SELinux status.\n";
		print "\t2) Fix currently installed yum groups.\n";
		print "\t3) Fix IPTables status.\n";
		print "\t4) Quit\n";
		print "Choice? ";

		chomp( my $choice = <STDIN> );
		if ( ! (looks_like_number($choice)) ) {
			print "Please enter a number\n";
		}

		if ( $choice == 1 ) {
			check_selinux($fix);
		}
		elsif ( $choice == 2 ) {
			check_yumgroups($fix);
		}
		elsif ( $choice == 3 ) {
			check_iptables($fix);
		}
		elsif ( $choice == 4 ) {
			$run = 0;
		}
		else {
			print "Please enter a number\n";
		}
	}
	elsif ( $fix == 0 ) {

		print "\nWhich would you like to do?\n";
		print "\t1) Check SELinux status.\n";
		print "\t2) Check currently installed yum groups.\n";
		print "\t3) Check IPTables status.\n";
		print "\t4) Quit\n";
		print "Choice? ";

		chomp( my $choice = <STDIN> );
		if ( ! (looks_like_number($choice)) ) {
			print "Please enter a number\n";
		}

		if ( $choice == 1 ) {
			check_selinux($fix);
		}
		elsif ( $choice == 2 ) {
			check_yumgroups($fix);
		}
		elsif ( $choice == 3 ) {
			check_iptables($fix);
		}
		elsif ( $choice == 4 ) {
			$run = 0;
		}
		else {
			print "Please enter a number\n";
		}

	}
}

sub check_selinux {

	my $fix = shift;
	
	my $file = '/etc/selinux/config';

	open( my $fh, "+<", $file ) or die "Cannot open selinux config file: $!";

	while( <$fh> ) {
		my $line = $_;
		if ( $line =~ /^SELINUX=(\w+)/ ) {
			if ( $fix ) {
				if ( $1 ne 'disabled' ) {
					$line = "SELINUX=disabled";
					print "Set SELINUX to disabled in $file\n";
				}
				else {
					print "SELinux is disabled already\n";
				}
			}
			else {
				print "\nSELinux is currently set to $1\n";
			}
		}
	}

	close $fh;
}

sub check_yumgroups {

	my $fix = shift;

	my %bad_groups = (
		'E-mail server'                           => 1,
		'FTP server'                              => 1,
		'KDE Desktop'                             => 1,
		'Web Server'                              => 1,
		'X Window System'                         => 1,
		'Desktop'                                 => 1,
		'Desktop Debugging and Performance Tools' => 1,
		'Desktop Platform'                        => 1,
		'Desktop Platform Development'            => 1,
		'General Purpose Desktop'                 => 1,
		'Legacy X Window System compatibility'    => 1,
		'Web Servlet Engine'                      => 1,
		'Web-Based Enterprise Management'         => 1,
	);

	my @installed_bad;

	open( my $output, "-|", "yum grouplist" ) or die "Problem with yum! $1";

	my $print = 0;

	while( <$output> ) {
		
		my $group = $_;
		$group =~ s/^\s+|\s+$//g;

		if ( $group =~ /Available Groups/ ) {
			$print = 0;
		}
		
		if ( $bad_groups{ $group } ) {
			push( @installed_bad, $group ) if $print;
		}

		if ( $group =~ /Installed Groups/ ) {
			$print = 1;
		}
	}

	close $output;

	if ( @installed_bad ) {
		if ( $fix ) {
			foreach my $bad (@installed_bad) {
				my $pid = open( my $out, "-|", "yum groupremove -y '$bad'" ) // die "Can't fork: $!";
				if ( $pid ) {
					waitpid $pid, 0;
					close $out;
				}
				print "Removed $bad\n";
			}
		}
		else {
			print "\nBad yum groups were found!\n";
			foreach my $bad (@installed_bad) {
				print "$bad\n";
			}
		}
	}
}

sub check_iptables {

	my $fix = shift;

	my $iptables = `chkconfig | grep iptables | awk '{for(i=2;i<=NF;++i)print \$i}'`;

	my @iptables = split( /:/, $iptables );

	if ( $fix ) {
		system( "service", "iptables", "save" );
		system( "service", "iptables", "stop" );
	}
	else {
		if ( $iptables[1] =~ /on/ || $iptables[2] =~ /on/ || $iptables[3] =~ /on/ || $iptables[4] =~ /on/ ) {
			print "\nIPTables is turned on, ensure there are no rules that would block ports that are needed\n";
		}
		else {
			print "\nIPTables is turned off\n";
		}
	}
}

#`rm -f $0`;
