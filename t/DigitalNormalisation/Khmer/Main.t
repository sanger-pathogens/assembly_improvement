#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use Cwd qw(abs_path);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::DigitalNormalisation::Khmer::Main');
}

my $current_dir = abs_path( getcwd() );

ok(
    (
    my $digi_norm = Bio::AssemblyImprovement::DigitalNormalisation::Khmer::Main->new(
            input_file     	=> 't/data/variable_length.fastq' ,
            khmer_exec      => $current_dir.'/t/dummy_normalise_script.py',
            python_exec     => 'python',
    	)
    ),
    'Object created OK'
);


# Test: Has the script produced an appropriately named results file?

ok($digi_norm->run(), 'Run the digital normalisation with a dummy script');

is(
  (join ('/', $current_dir, 'digitally_normalised.fastq.gz')), 
  $digi_norm->_final_results_file,
  'Default results file name ok');


ok(-e $digi_norm->_final_results_file, 'Digital normalised file exists in expected location');

unlink($digi_norm->_final_results_file);

done_testing();
