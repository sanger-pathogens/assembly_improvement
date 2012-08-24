#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift(@INC, './lib') }
BEGIN {
    use Test::Most;
    my @all_modules;
    my $cmd = "grep -R package ./lib | awk '{print \$2};' | ";

    open(my $modules, $cmd) or die "Couldnt open lib directory";
    while(<$modules>)
    {
      chomp;
      my $line = $_;
      $line =~ s!;$!!;
      use_ok($line);
    }
     done_testing();
}

