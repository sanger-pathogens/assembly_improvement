#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use Cwd qw(abs_path);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
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

done_testing();