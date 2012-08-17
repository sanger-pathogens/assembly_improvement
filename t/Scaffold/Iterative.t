#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;

BEGIN { unshift( @INC, './modules' ) }

BEGIN {
    use Test::Most;
    use_ok('Pathogen::Scaffold::SSpace::Iterative');
}

my $cwd = getcwd();

ok((my $iterative_scaffolding = Pathogen::Scaffold::SSpace::Iterative->new(
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

is($iterative_scaffolding->_final_output_filename, $cwd.'/contigs.scaffolded.fa', 'final scaffolded filename');
ok((-e $iterative_scaffolding->_final_output_filename),'Scaffolding file exists in expected location');

unlink('contigs.scaffolded.fa');
done_testing();