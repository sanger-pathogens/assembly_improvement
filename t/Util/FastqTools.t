#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Util::FastqTools');
}

ok(
	(
		my $fastq_processor  = Bio::AssemblyImprovement::Util::FastqTools->new(
    		input_filename   => 't/data/variable_length.fastq', 
		)
	),
	'Create an object with fastq file'
);


#$fastq_processor->draw_histogram_of_read_lengths(); 

my %kmer_sizes = $fastq_processor->calculate_kmer_sizes();
is($kmer_sizes{min},99, 'Minimum kmer size ok');
is($kmer_sizes{max},135, 'Maximum kmer size ok');

my $coverage = $fastq_processor->calculate_coverage(300);
is($coverage,2, 'Coverage is ok');

done_testing();