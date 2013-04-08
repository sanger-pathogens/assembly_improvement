#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use Cwd qw(abs_path);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::PrimerRemoval::Main');
}

my $current_dir = abs_path( getcwd() );

ok(
    (
    my $primer_remover = Bio::AssemblyImprovement::PrimerRemoval::Main->new(
            input_file     	=> $current_dir.'/t/data/shuffled.fastq' ,
      		primers_file	=> $current_dir.'/t/data/primers.txt',
      		QUASR_exec		=> $current_dir.'/t/DummyQUASR.jar',
    	)
    ),
    'Object created OK'
);


# Test: Has the script produced an appropriately named results file?

ok($primer_remover->run(), 'Run the primer removal with a dummy script');

is(
  (join ('/', $current_dir, 'primer_removed.qc.fastq.gz')), 
  $primer_remover->_final_results_file,
  'Default results file name ok');

ok(-e $primer_remover->_final_results_file, 'Results file exists in expected location');

unlink($primer_remover->_final_results_file); #Clean up after ourselves

done_testing();
