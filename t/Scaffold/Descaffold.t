#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Scaffold::Descaffold');
}

ok((my $descaffold_obj = Bio::AssemblyImprovement::Scaffold::Descaffold->new(
  input_assembly => 't/data/contigs.scaffolded.fa'
)), 'initialise descaffolding');

ok($descaffold_obj->run(), 'Run the descaffolder');
is($descaffold_obj->output_filename, 't/data/contigs.scaffolded.fa.descaffolded', 'Is the output name as expected');

compare_files($descaffold_obj->output_filename, 't/data/contigs.scaffolded.fa.descaffolded.expected');
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
