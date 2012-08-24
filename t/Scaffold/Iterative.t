#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use File::Path qw(make_path remove_tree);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Scaffold::SSpace::Iterative');
}

my $cwd = getcwd();

ok((my $iterative_scaffolding = Bio::AssemblyImprovement::Scaffold::SSpace::Iterative->new(
  input_files => [ 't/data/forward.fastq', 't/data/reverse.fastq' ],
  input_assembly => 't/data/contigs.fa',
  insert_size => 250,
  scaffolder_exec => $cwd.'/t/dummy_sspace_script.pl',
  debug  => 0
)),'Create overall iterative object');
is_deeply($iterative_scaffolding->merge_sizes, [ 90, 80, 70, 60, 50, 40, 30, 25, 20, 15, 10, 10, 7, 7, 5, 5 ], 'iteration merge sizes');
isnt($iterative_scaffolding->_intermediate_filename,'t/data/contigs.fa','Intermediate filename isnt the same as the input assembly');
ok(($iterative_scaffolding->_intermediate_filename  =~ m/contigs\.fa$/),'Intermediate filename has same base as input assembly');
ok($iterative_scaffolding->run, 'Run the scaffolder with a dummy script');
is($iterative_scaffolding->final_output_filename, $cwd.'/contigs.scaffolded.fa', 'final scaffolded filename');
ok((-e $iterative_scaffolding->final_output_filename),'Scaffolding file exists in expected location');
unlink('contigs.scaffolded.fa');


make_path("different_directory");
ok(($iterative_scaffolding = Bio::AssemblyImprovement::Scaffold::SSpace::Iterative->new(
  input_files => [ 't/data/forward.fastq', 't/data/reverse.fastq' ],
  input_assembly => 't/data/contigs.fa',
  insert_size => 250,
  scaffolder_exec => $cwd.'/t/dummy_sspace_script.pl',
  debug  => 0,
  output_base_directory => 'different_directory'
)),'Create overall iterative object');
ok($iterative_scaffolding->run, 'Run the scaffolder with a dummy script');
is($iterative_scaffolding->final_output_filename, 'different_directory/contigs.scaffolded.fa', 'final scaffolded filename');
ok((-e $iterative_scaffolding->final_output_filename),'Scaffolding file exists in expected location');
remove_tree("different_directory");



done_testing();
