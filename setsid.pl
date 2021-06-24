#!/usr/bin/env perl
# 
# A Perl implementation of setsid(1)
#
# setsid(1) - run a program in a new session
# http://man7.org/linux/man-pages/man1/setsid.1.html
# https://perldoc.perl.org/POSIX

use POSIX ();

fork() && exit;
POSIX::setsid() or die $!;

my $METHOD = 'EXEC';

if( substr($ARGV[0],0,1) eq '-' ){
    my $param = shift @ARGV;
    $METHOD = 'SYSTEM' if $param eq '-w';
}

if( $METHOD eq 'EXEC' ){
    exec @ARGV;
}elsif( $METHOD eq 'SYSTEM' ){
    system @ARGV;
    exit $?;
}
