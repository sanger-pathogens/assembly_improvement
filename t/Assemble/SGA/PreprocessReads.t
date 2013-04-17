#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use Cwd;
use Cwd qw(abs_path);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads');
}

my $current_dir = abs_path( getcwd() );

# Test: Have input files being unzipped (if zipped), named appropriately and put into a temporary directory?

ok(
    (
    my $sga_preprocessor = Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads->new(
            input_files     => [ 't/data/forward.fastq', 't/data/reverse.fastq.gz' ] ,
            pe_mode			=> 1,
            sga_exec        => $current_dir.'/t/dummy_sga_script',
    	)
    ),
    'Created with two fastq files; some zipped.'
);

my $prepared_input_files = $sga_preprocessor->_prepare_input_files();

my $forward_filename_post_unzip = fileparse($prepared_input_files->[0] );
# test (got, expected, message)
is($forward_filename_post_unzip, 'forward.fastq', 'correct unzipped forward filename');

my $reverse_filename_post_unzip = fileparse($prepared_input_files->[1] );
is($reverse_filename_post_unzip, 'reverse.fastq', 'correct unzipped reverse filename');

ok((-e (join ('/', $sga_preprocessor->_temp_directory, $reverse_filename_post_unzip))),
   'Reversed unzipped file exists in correct location');

# Test: Has the read preprocess stage of SGA created an appropriately named FASTQ file?

ok($sga_preprocessor->run(), 'Run the SGA preprocess step with a dummy script');

is(
  (join ('/', $sga_preprocessor->_temp_directory, '_sga_preprocessed.fastq')), 
  $sga_preprocessor->_output_filename,
  'Default results file name ok');


ok(-e $sga_preprocessor->_output_filename(),
   'SGA preprocessed file exists in expected location');
   
   
# Test: Can the pre-processor accept 1 shuffled file?

ok(
    (
    my $sga_preprocessor_shuffled = Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads->new(
            input_files     => [ 't/data/shuffled.fastq' ] ,
            sga_exec        => $current_dir.'/t/dummy_sga_script',
      )
    ),
    'shuffled fastq'
);

ok($sga_preprocessor_shuffled->run(), 'Run the SGA preprocess (shuffled) step with a dummy script');

ok(-e $sga_preprocessor_shuffled->_output_filename(),
   'SGA preprocessed file exists in expected location');
   
# Clean up
unlink($sga_preprocessor->_output_filename());
unlink($sga_preprocessor_shuffled->_output_filename());

  

done_testing();
