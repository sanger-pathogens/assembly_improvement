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

my $data_dir              = 't/data';
my $input_file            = 'contigs_needing_sorted.fa';
my $output_filename       = 'contigs_needing_sorted.fa.sorted';
my $expected_sorted_file  = 'expected_contigs_needing_sorted.fa';

# work in temp directory
my $temp_directory_obj = File::Temp->newdir( CLEANUP => 1 );
my $temp_directory = $temp_directory_obj->dirname();
copy(join('/',($data_dir,$input_file)), $temp_directory);

# instantiate
ok my $sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => join('/',($temp_directory,$input_file)) ), 'instantiate object';
is $sort_contigs->output_filename(), join('/',($temp_directory,$output_filename)), 'output filename correct';

# sort config
ok $sort_contigs->run(), 'sort contigs';
files_eq($sort_contigs->output_filename(),join('/',($data_dir,$expected_sorted_file)));
my $user_file_name = join('/',($temp_directory,'user_file_name.fa'));
ok $sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => join('/',($temp_directory,$input_file)), output_filename => $user_file_name ), 'use user outfile';
is $sort_contigs->output_filename(), $user_file_name, 'confirm set user outfile';
ok $sort_contigs->run(), 'sort contigs';
files_eq($user_file_name,join('/',($data_dir,$expected_sorted_file)));

# check renumber function
ok $sort_contigs->contig_basename('sorted'), 'set contig basename';
is $sort_contigs->_rename_contig(99), 'sorted99', 'renamed contig with new contig basename';

done_testing();
