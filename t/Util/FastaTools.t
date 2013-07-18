#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use Cwd qw(abs_path);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use Test::File::Contents;
    use_ok('Bio::AssemblyImprovement::Util::FastaTools');
}

# Test: Is the object created OK?
my $current_dir = getcwd();

ok(
	(
		my $fasta_processor  = Bio::AssemblyImprovement::Util::FastaTools->new(
    		input_filename   =>  $current_dir.'/t/data/contigs_for_filtering.fa',
		)
	),
	'Creating an object OK'
);


# Test: remove_small_contigs
my $filtered = $fasta_processor->remove_small_contigs($current_dir . '/filtered_test.fa', 1, 90);
files_eq($filtered, $current_dir . '/t/data/contigs_for_filtering.fa.filtered.min_len_1.fa', 'Filter min length 1');
isnt($filtered, $fasta_processor->input_filename, 'Filter min length 1 returned correct filename');

$filtered = $fasta_processor->remove_small_contigs($current_dir . '/filtered_test.fa', 2, 90);
files_eq($filtered, $current_dir . '/t/data/contigs_for_filtering.fa.filtered.min_len_2.fa', 'Filter min length 2');
isnt($filtered, $fasta_processor->input_filename, 'Filter min length 2 returned correct filename');

$filtered = $fasta_processor->remove_small_contigs($current_dir . '/filtered_test.fa', 4, 90);
is($filtered, $fasta_processor->input_filename, 'No filter when too many bases are lost from filtering');

done_testing();
