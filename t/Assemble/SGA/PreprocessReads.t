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
            sga_exec        => $current_dir.'/t/dummy_sga_script',
    	)
    ),
    'some zipped'
);

my $prepared_input_files = $sga_preprocessor->_prepare_input_files();

my $forward_filename_post_unzip = fileparse($prepared_input_files->[0] );
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

done_testing();
