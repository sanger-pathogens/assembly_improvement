#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use File::Path qw(make_path remove_tree);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::FillGaps::GapFiller::Iterative');
}

my $cwd = getcwd();

ok((my $iterative_scaffolding = Bio::AssemblyImprovement::FillGaps::GapFiller::Iterative->new(
  input_files => [ 't/data/forward.fastq', 't/data/reverse.fastq' ],
  input_assembly => 't/data/contigs.fa',
  insert_size => 250,
  threads => 2,
  gap_filler_exec => $cwd.'/t/dummy_gap_filler_script.pl',
  _output_prefix => 'gapfilled',
  debug  => 0,
)),'Create overall iterative object');
is_deeply($iterative_scaffolding->merge_sizes, [ 90, 70, 50, 30, 20, 10], 'iteration merge sizes');
isnt($iterative_scaffolding->_intermediate_filename,'t/data/contigs.fa','Intermediate filename isnt the same as the input assembly');
ok(($iterative_scaffolding->_intermediate_filename  =~ m/contigs\.fa$/),'Intermediate filename has same base as input assembly');
ok($iterative_scaffolding->run, 'Run the scaffolder with a dummy script');
is($iterative_scaffolding->final_output_filename, $cwd.'/contigs.gapfilled.fa', 'final gapfilled filename');
ok((-e $iterative_scaffolding->final_output_filename),'gap filled file exists in expected location');
unlink('contigs.gapfilled.fa');



make_path("different_directory");
ok(($iterative_scaffolding = Bio::AssemblyImprovement::FillGaps::GapFiller::Iterative->new(
  input_files => [ 't/data/forward.fastq', 't/data/reverse.fastq' ],
  input_assembly => 't/data/contigs.fa',
  insert_size => 250,
  gap_filler_exec => $cwd.'/t/dummy_gap_filler_script.pl',
  _output_prefix => 'gapfilled',
  debug  => 0,
  output_base_directory => 'different_directory'
)),'Create overall iterative object');
ok($iterative_scaffolding->run, 'Run the scaffolder with a dummy script');
is($iterative_scaffolding->final_output_filename, 'different_directory/contigs.gapfilled.fa', 'final gapfilled filename');
ok((-e $iterative_scaffolding->final_output_filename),'gap filled file exists in expected location');
remove_tree("different_directory");



done_testing();
