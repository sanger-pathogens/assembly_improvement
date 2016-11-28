#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use File::Path qw( rmtree );
use File::Slurper;

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

ok(-e "circularised/circlator.info.txt", "circlator.info.txt exists OK");
ok(-e "circularised/circlator.log", "circlator.log exists OK");
ok(-e "circularised/circlator.final.fasta", "circlator.final.fasta exists OK");

my $expected_log = read_text($current_dir.'/t/data/expected_circlator.log');
my $got_log = read_text("circularised/circlator.log");
is($got_log, $expected_log, "Logs concatenated in right order");

opendir my $dh, "circularised" or warn "opendir circularised - $!";
my @files = readdir $dh;
is( @files - 2, 3, "File count OK"); # subtract 2 because readdir returns . and .. files too

rmtree('circularised');

#--- test case when no merge.merge.log file is created ----#

ok(my $obj_no_merge = Bio::AssemblyImprovement::Circlator::Main->new(
    'assembly'      	  => $current_dir.'/t/data/contigs.fa',
    'corrected_reads'     => $current_dir.'/t/data/shuffled.fastq',
    'circlator_exec'      => $current_dir.'/t/dummy_circlator_script_no_merge_log',
), 'initialize object');

$obj_no_merge->run();

my $expected_log_no_merge = read_text($current_dir.'/t/data/expected_circlator_no_merge.log');
my $got_log_no_merge = read_text("circularised/circlator.log");
is($got_log_no_merge, $expected_log_no_merge, "Logs concatenated in right order");

rmtree('circularised');

done_testing();
