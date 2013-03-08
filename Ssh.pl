#!/usr/bin/perl

use strict;
use Cwd            qw( abs_path );
use File::Basename qw( dirname );

# strict don't  like boolean
use constant false => 0;
use constant true  => 1;

# Ssh.pl script path
my $path = dirname(abs_path($0));

# You could change these if you must
my $sshagent = '/usr/bin/ssh-agent -l';
my $hostname = `/bin/hostname -s`;
my $conffile = "$path/Ssh_hosts.conf";

# Who to connect to
my $ghost = $ARGV[0] if $ARGV[0];

# Obvious hashes 
my %ips;
my %ports;
my %usernames;
my %servers;
my %options;

# Gotta load hashes
loadHosts();
loadAgent();

# No one to connect to
if (!$ghost){
  printMenu();

# Connect to...
}else{
  my $check = checkHost();
  if ($check){
    system "echo \"\\033]0;$servers{$check}\\007\"";
    system "ssh -p $ports{$check} -l $usernames{$check} $ips{$check} $options{$check}\n";
    system "echo \"\\033]0;$hostname\\007\"";
  }else{
    print "-------------------\n";
    print "No host by that name!: $ghost\n";
    printMenu();
  }
}

# Check if argument is a valid host
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

# Just prints the menu
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

# Get the hashes loaded
sub loadHosts (){
  my @file = `cat $conffile`;
  my $i = 1;
  for my $line (@file){
    if ($line !~ /$\#/){
      $line =~ s/\n//g;
      my @split = split (",",$line);
      $servers{$i}   = $split[0];
      $usernames{$i} = $split[1];
      $ips{$i}       = $split[2];
      $ports{$i}     = $split[3];
      $options{$i}   = $split[4];
      $i++;
    }
  }
}

# load de ssh-agent if it is not running
sub loadAgent(){
  # This should be better...
  my $agentpid = `ps auxww | grep -i ssh-agent | grep -v grep`;
  if ($agentpid){
    return;
  }else{
    print $sshagent;
  }
}
