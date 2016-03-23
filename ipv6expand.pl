#!/usr/bin/env perl

use strict;
use warnings;

sub count_groups { # See hown many groups we have
	die "Too many arguments for subroutine" if @_ < 1;
	die "Too few arguments for subroutine" if @_ > 1;
	my $address = shift;
	
	# Make sure we have just enough double colons and count them if it is all right
	my $colon_no =  () = $address =~ /::/g;
	die "Invalid ipv6 address" if $colon_no > 1;
	my $no =  1;
	$no += () = $address =~ /:/g;
	return $no;

}

# If we have one occurence of :: replace with correct amount of zeros and colons
sub expand_void {
	die "Too many arguments for subroutine" if @_ < 1;
	die "Too few arguments for subroutine" if @_ > 1;
	my $address = shift;
	my $no_colons = 8 - count_groups($address);
	my $insert = "0000:0000";
	for (my $i = 0; $i < $no_colons - 1; $i++) {
		$insert = $insert . ":0000"
	}
	$address =~ s/::/:$insert:/g;
	return $address;

}

# Fix a single group and padd with zeros
sub fix_group {
	die "Too many arguments for subroutine" if @_ < 1;
	die "Too few arguments for subroutine" if @_ > 1;
	my $group = shift;
	my $len = length($group);
	die "Group has too many digits" if $len > 4;
	while ($len < 4) {
		$group = "0$group";
		$len++;		

	}
	# Make sure it is a valid hexnumber
	die "Group is not a hex number" if $group !~ /^[0-9a-fA-F]+$/;
	return $group;
	
}

# Loop all groups and fix them with fix_group
sub fix_groups {
	die "Too many arguments for subroutine" if @_ < 1;
	die "Too few arguments for subroutine" if @_ > 1;
	my $a = shift;
	my @groups = split(/:/, $a);
	my $address = "";
	foreach my $group (@groups) {
		$group = fix_group($group);
		$address = "$address$group:";
	}
	
	$address =~ s/:+$//; 
	return $address;
}

# Now put it together
# Loop through stdin
while (<>) {
	chomp; # Remove newline
	my $addr = $_; # Store address

	if (count_groups($addr) != 8) {
		$addr = expand_void($addr);
	}
	
	$addr = fix_groups($addr);

	# Double check that we have enough groups one last time
	die "Not a valid ipv6 address" if count_groups($addr) != 8;

	# Lower case is preffered for ipv6 adresses
	print lc "$addr\n";
	
}

exit 0;
