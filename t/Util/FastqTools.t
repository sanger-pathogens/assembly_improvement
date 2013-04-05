#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use Cwd qw(abs_path);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use Test::File::Contents;
    use_ok('Bio::AssemblyImprovement::Util::FastqTools');
}

# Test: Is the object created OK with a zipped fastq file?
my $current_dir = getcwd();

ok(
	(
		my $fastq_processor  = Bio::AssemblyImprovement::Util::FastqTools->new(
    		input_filename   =>  $current_dir.'/t/data/variable_length_zipped.fastq.gz', 
		)
	),
	'Creating an object with a zipped fastq file OK'
);


#$fastq_processor->draw_histogram_of_read_lengths(); 

# Test: kmer sizes
my %kmer_sizes = $fastq_processor->calculate_kmer_sizes();
is($kmer_sizes{min},99, 'Minimum kmer size ok');
is($kmer_sizes{max},135, 'Maximum kmer size ok');

# Test: coverage
my $coverage = $fastq_processor->calculate_coverage(300);
is($coverage,2, 'Coverage is ok');


ok(
	(
		my $fastq_processor_2  = Bio::AssemblyImprovement::Util::FastqTools->new(
    		input_filename   =>  $current_dir.'/t/data/shuffled.fastq', 
		)
	),
	'Creating an object with a shuffled fastq file OK'
);

# Test: splitting a shuffled fastq file
$fastq_processor_2->split_fastq('forward_test.fastq', 'reverse_test.fastq');
files_eq($current_dir.'/forward_test.fastq', $current_dir.'/t/data/split_forward.fastq', "Forward reads split ok");
files_eq($current_dir.'/reverse_test.fastq', $current_dir.'/t/data/split_reverse.fastq', "Reverse reads split ok");



done_testing();