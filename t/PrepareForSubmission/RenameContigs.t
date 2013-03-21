#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp;
use File::Copy;
use File::Slurp;


BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::PrepareForSubmission::RenameContigs');
}

my $tmp_file_obj = File::Temp->new();
my $original_assembly = 't/data/contigs_needing_to_be_renamed.fa';
my $pre_processed_assembly  = read_file($original_assembly);
my $expected_post_processed_assembly =  read_file('t/data/expected_contigs_needing_to_be_renamed.fa');

copy($original_assembly, $tmp_file_obj->filename);

ok(my $obj = Bio::AssemblyImprovement::PrepareForSubmission::RenameContigs->new(
  input_assembly => $tmp_file_obj->filename,
  base_contig_name => 'ERS00001234'
)->run(),'Update the input file so that the contig names are renamed');

is($obj->_generate_contig_name(5),'ERS00001234.5', 'Contig names follow convention');

my $post_processed_assembly  = read_file($obj->input_assembly);
isnt($post_processed_assembly, $pre_processed_assembly , 'Input and output assemblies should not be the same');
is($expected_post_processed_assembly,$post_processed_assembly, 'Output assembly has correct naming scheme' );


ok($obj = Bio::AssemblyImprovement::PrepareForSubmission::RenameContigs->new(
  input_assembly => $tmp_file_obj->filename,
  base_contig_name => '_1234#.efg'
),'base contig name with non word characters');
is($obj->_generate_contig_name(5),'_1234_.efg.5', 'Non word characters replaced with underscores');


ok($obj = Bio::AssemblyImprovement::PrepareForSubmission::RenameContigs->new(
  input_assembly => $tmp_file_obj->filename,
  base_contig_name => 'ERS001935.3555_2'
),'Dont replace full stops with underscores');
is($obj->_generate_contig_name(5),'ERS001935.3555_2.5', 'Dont replace full stops with underscores');

ok($obj = Bio::AssemblyImprovement::PrepareForSubmission::RenameContigs->new(
  input_assembly => $tmp_file_obj->filename,
  base_contig_name => '.3555_2'
),'allow fullstop as first character');
is($obj->_generate_contig_name(5),'.3555_2.5', 'allow fullstop as first character');

done_testing();