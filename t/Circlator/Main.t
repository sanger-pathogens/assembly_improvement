#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use File::Path qw( rmtree );
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Circlator::Main');
}

my $current_dir = getcwd();

ok(my $obj = Bio::AssemblyImprovement::Circlator::Main->new(
    'assembly'      	  => $current_dir.'/t/data/contigs.fa',
    'corrected_reads'     => $current_dir.'/t/data/shuffled.fastq',
    'circlator_exec'      => $current_dir.'/t/dummy_circlator_script',
), 'initialize object');

$obj->run();

ok(-e "circularised/06.fixstart.fasta", "06.fixstart.fasta exists OK");
ok(-e "circularised/06.fixstart.ALL_FINISHED", "06.fixstart.ALL_FINISIHED exists OK");
ok(-e "circularised/circlator.info.txt", "circlator.info.txt exists OK");
ok(-e "circularised/circlator.log", "circlator.log exists OK");

my $expected_log = read_file($current_dir.'/t/data/expected_circlator.log');
my $got_log = read_file("circularised/circlator.log");
is($got_log, $expected_log, "Logs concatenated in right order");

opendir my $dh, "circularised" or warn "opendir circularised - $!";
my @files = readdir $dh;
is( @files - 2, 4, "File count OK"); # subtract 2 because readdir returns . and .. files too

rmtree('circularised');

done_testing();
