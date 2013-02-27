#!/usr/bin/perl

use strict;
use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use constant false => 0;
use constant true  => 1;

my $sshagent="/usr/bin/ssh-agent -l";
my $path=dirname(abs_path($0));

my $ghost = $ARGV[0] if $ARGV[0];
my %ips;
my %ports;
my %usernames;
my %servers;
my %options;

loadHosts();
loadAgent();

if (!$ghost){
	printMenu();
}else{
	my $check = checkHost();
	if ($check){
		system "echo \"\\033]0;$servers{$check}\\007\"";
		system "ssh -p $ports{$check} -l $usernames{$check} $ips{$check} $options{$check}\n";
		system "echo -n -e \"\\033]0;Mac\\007\"";
	}else{
		print "-------------------\n";
		print "No host by that name!: $ghost\n";
		printMenu();
	}
}

sub checkHost(){
	for my $key (keys %servers){
		if ("$ghost" eq "$servers{$key}"){
			return $key;
		}
		if ($ghost > 0 && $ghost < keys(%ips)+1){
			return "$ghost";
		}
	}
	return false;
}

sub printMenu (){
	print "-------------------\n";
	print "Hosts:\n";
	my $i = 1;
	for $i (1..keys(%ips)){
		print "$i->";
		print "$servers{$i}";
		print " ($ips{$i}:$ports{$i})";
		print " ($options{$i})\n";
	}
	print "-------------------\n";
}

sub loadHosts (){
	my @file = `cat $path/Ssh_hosts.txt`;
	my $i = 1;
	for my $line (@file){
		if ($line !~ /$\#/){
			$line =~ s/\n//g;
			my @split = split (",",$line);
			$servers{$i} = $split[0];
			$usernames{$i} = $split[1];
			$ips{$i} = $split[2];
			$ports{$i} = $split[3];
			$options{$i} = $split[4];
			$i++;
		}
	}
}

sub loadAgent(){
	my $agentpid = `ps auxww | grep -i ssh-agent | grep -v grep`;
	if ($agentpid){
		return;
	}else{
		print $sshagent;
	}
}
