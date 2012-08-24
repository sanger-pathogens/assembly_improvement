#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use Cwd 'abs_path';
use File::Path qw(make_path remove_tree);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Abacas::Main');
}

my $cwd = getcwd();
ok((my $abacas_obj = Bio::AssemblyImprovement::Abacas::Main->new(
  input_assembly => 't/data/contigs.fa',
  reference      => 't/data/my_reference.fa',
  abacas_exec => $cwd.'/t/dummy_abacas_script.pl',
  debug  => 0
)),'Create overall main object');

isnt($abacas_obj->_intermediate_file_name,'t/data/contigs.fa','Intermediate filename isnt the same as the input assembly');
ok(($abacas_obj->_intermediate_file_name  =~ m/contigs\.fa_my_reference\.fa\.fasta$/),'Intermediate filename has same base as input assembly');
ok($abacas_obj->run, 'Run the scaffolder with a dummy script');
is($abacas_obj->final_output_filename, $cwd.'/contigs.scaffolded.fa', 'final scaffolded filename');
ok((-e $abacas_obj->final_output_filename),'Scaffolding file exists in expected location');
unlink('contigs.scaffolded.fa');

my $output_directory = abs_path('different_directory' );
make_path($output_directory);
ok(($abacas_obj = Bio::AssemblyImprovement::Abacas::Main->new(
  input_assembly => 't/data/contigs.fa',
  reference      => 't/data/my_reference.fa',
  abacas_exec => $cwd.'/t/dummy_abacas_script.pl',
  debug  => 0,
  output_base_directory => $output_directory
)),'Create overall main object');
ok($abacas_obj->run, 'Run the scaffolder with a dummy script');
is($abacas_obj->final_output_filename, $output_directory.'/contigs.scaffolded.fa', 'final scaffolded filename');
ok((-e $abacas_obj->final_output_filename),'Scaffolding file exists in expected location');
remove_tree("different_directory");


ok(($abacas_obj = Bio::AssemblyImprovement::Abacas::Main->new(
  input_assembly => 't/data/contigs.fa',
  reference      => 't/data/reference_over_multiple_lines.fa',
  abacas_exec => $cwd.'/t/dummy_abacas_script.pl',
  debug  => 0
)),'Create overall main object where reference is split over multiple lines');
is(
  ($abacas_obj->_merge_contigs_into_one_sequence('t/data/reference_over_multiple_lines.fa')),
  $abacas_obj->_temp_directory.'/reference_over_multiple_lines.fa.union.fa',
  'New merged reference is outputted'
);
compare_files($abacas_obj->_temp_directory.'/reference_over_multiple_lines.fa.union.fa', 't/data/expected_reference_over_multiple_lines.fa.union.fa');
is(
  ($abacas_obj->_split_sequence_on_delimiter($abacas_obj->_temp_directory.'/reference_over_multiple_lines.fa.union.fa')),
  $abacas_obj->_temp_directory.'/reference_over_multiple_lines.fa.union.fa.split.fa',
  'Split reference is outputted'
);
compare_files($abacas_obj->_temp_directory.'/reference_over_multiple_lines.fa.union.fa.split.fa', 't/data/reference_over_multiple_lines.fa');

done_testing();


sub compare_files
{
  my($expected_file, $actual_file) = @_;
  ok((-e $actual_file),' results file exist');
  ok((-e $expected_file)," $expected_file expected file exist");
  local $/ = undef;
  open(EXPECTED, $expected_file);
  open(ACTUAL, $actual_file);
  my $expected_line = <EXPECTED>;
  my $actual_line = <ACTUAL>;
  
  # parallel processes mean the order isnt guaranteed.
  my @split_expected  = split(/\n/,$expected_line);
  my @split_actual  = split(/\n/,$actual_line);
  my @sorted_expected = sort(@split_expected);
  my @sorted_actual  = sort(@split_actual);
  
  is_deeply(\@sorted_expected,\@sorted_actual, "Content matches expected $expected_file");
}
