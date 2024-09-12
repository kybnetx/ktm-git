#!/usr/bin/perl -w

use strict;
use warnings;
use Digest::SHA1;
use Term::ReadKey;

sub get_pass {
    ReadMode 'noecho';
    chomp( my $pw = ReadLine 0 );
    ReadMode 'normal';
    return $pw;
}

print "Enter the password to be encrypted: ";
my $pass = get_pass();

print "\nConfirm the password: ";
my $verify = get_pass();

if ( $pass eq $verify ) {
    my $sha1_enc = Digest::SHA1->new;
    $sha1_enc->add($pass);

    print "\nYour encrypted password is: "
      . $sha1_enc->hexdigest . "\n"
      . "Paste this into your SQL INSERT/COPY Data.\n";
}
else {
    print "\nPasswords do not match!\n";
}
