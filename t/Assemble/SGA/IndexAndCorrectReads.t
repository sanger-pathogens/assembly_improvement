#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use Cwd;
use Cwd qw(abs_path);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads');
}

my $current_dir = abs_path( getcwd() );

ok(
    (
     my $sga_error_corrector = Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads->new(
      	input_filename => '_sga_preprocessed.fastq',
      	algorithm      => 'ropebwt',
      	threads        => 8,
      	kmer_length	 => 41,
      	sga_exec        => $current_dir.'/t/dummy_sga_script',
      	)->run()
     ),
   'Create and run IndexAndCorrectReads object with a dummy script'
);

my $base_filename = fileparse( $sga_error_corrector->input_filename, qr/\.[^.]*/ );

# Test: Are the intermediate index files produced?

ok((-e (join ('/', $sga_error_corrector->_temp_directory, $base_filename.'.bwt'))),
   '.bwt index file exists in right location');
ok((-e (join ('/', $sga_error_corrector->_temp_directory, $base_filename.'.sai'))),
   '.sai index file exists in right location');

# Test: Has the final fastq file being produced with the corrected reads?

ok(-e $sga_error_corrector->_output_filename(), 'Final fastq file exists in right location');
   
done_testing();

