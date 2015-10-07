#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use File::Path qw( rmtree );

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

rmtree('circularised');

done_testing();
