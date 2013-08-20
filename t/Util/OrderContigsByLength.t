#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp;
use File::Copy;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use Test::File::Contents;
    use_ok('Bio::AssemblyImprovement::Util::OrderContigsByLength');
}

my $input_file  = 't/data/contigs_needing_sorted.fa';
my $expected_output_file = 't/data/contigs_sorted.fa';

my $temp_input_file  = File::Temp->new(TEMPLATE => 'contig_XXXXXX', SUFFIX => '.fa');
my $temp_output_file = File::Temp->new(TEMPLATE => 'contig_XXXXXX', SUFFIX => '.fa');

# sort contigs making new file
ok my $sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => $input_file, 
                                                                                 output_filename => $temp_output_file->filename ), 'instantiate object (sort to output file)';

ok $sort_contigs->run(), 'sort contigs';
files_eq($temp_output_file->filename,$expected_output_file);

# sort contigs and replace file
copy($input_file,$temp_input_file->filename);
ok my $sort_contigs_ii = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename => $temp_input_file->filename ), 'instantiate object (sort input file)';

ok $sort_contigs_ii->run(), 'sort contigs';
files_eq($temp_input_file->filename, $expected_output_file);

done_testing();
