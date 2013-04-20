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
            forward_file    => $current_dir.'/t/data/forward.fastq' ,
            reverse_file    => $current_dir.'/t/data/reverse.fastq' ,
      		primers_file	=> $current_dir.'/t/data/primers.txt',
      		QUASR_exec		=> $current_dir.'/t/DummyQUASR.jar',
    	)
    ),
    'Object created OK'
);


# Test: Has the script produced appropriately named results files?

ok($primer_remover->run(), 'Run the primer removal with a dummy script');

my @final_results = $primer_remover->_final_results_files;
my @expected_results = ($current_dir.'/primer_removed.forward.fastq.gz', $current_dir.'/primer_removed.reverse.fastq.gz');

is_deeply(\@final_results, \@expected_results, 'Results files named ok');
  
foreach (@final_results){
	ok(-e $_, 'Results file exists in expected location');
	unlink($_); #Clean up after ourselves

}
done_testing();
