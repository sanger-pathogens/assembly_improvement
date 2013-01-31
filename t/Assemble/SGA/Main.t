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

my $current_dir = abs_path( getcwd() );

# Test: Has SGA 'preprocess' and 'correct' been run on input files?

ok(
    (
    my $sga = Bio::AssemblyImprovement::Assemble::SGA::Main->new(
            input_files     => [ 't/data/forward.fastq', 't/data/reverse.fastq' ] ,
            algorithm      	=> 'ropebwt',
      		threads         => 8,
      		kmer_length	    => 40,
            sga_exec        => $current_dir.'/t/dummy_sga_script.pl',
            output_directory => _temp_directory,
    	)
    ),
    'Create Bio::AssemblyImprovement::Assemble::SGA::Main object '
);

ok($sga->run(), 'Run the SGA preprocess and correct steps with dummy scripts');

is(
  (join ('/', $sga->_temp_directory, '_sga_preprocessed_and_corrected.fastq')), 
  $sga->_output_filename,
  'Default results file name ok');

#ok(-e $sga->_output_filename(), 'SGA results file exists in expected location');

done_testing();