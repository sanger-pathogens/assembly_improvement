#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use Cwd;
use Cwd qw(abs_path);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Assemble::SGA::Main');
}

my $current_dir = getcwd();



ok(
    (
    my $sga = Bio::AssemblyImprovement::Assemble::SGA::Main->new(
            input_files     => [ $current_dir.'/t/data/forward.fastq', $current_dir.'/t/data/reverse.fastq' ] ,
            algorithm      	=> 'ropebwt',
      		threads         => 8,
      		kmer_length	    => 40,
            sga_exec        => $current_dir.'/t/dummy_sga_script',
    	)
    ),
    'Create Bio::AssemblyImprovement::Assemble::SGA::Main object '
);

ok($sga->run(), 'Run the SGA preprocess and correct steps with dummy scripts');

# is (got, expected, name)

# Test: Is the name of the results file as expected?
is(
    $sga->_final_results_file,
    join ('/', $current_dir, '_sga_error_corrected.fastq'),   
   'Default results file name ok');

# Test: Is the results file available?
ok(-e $sga->_final_results_file, 'SGA results file exists in expected location');

unlink($sga->_final_results_file);

done_testing();