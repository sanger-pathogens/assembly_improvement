#!/usr/bin/env perl
use strict;
use warnings;


BEGIN { unshift( @INC, './modules' ) }

BEGIN {
    use Test::Most;
    use_ok('Pathogen::Scaffold::SSpace::Iterative');
}

ok((my $iterative_scaffolding = Pathogen::Scaffold::SSpace::Iterative->new(
  input_files => [ 't/data/forward.fastq', 't/data/reverse.fastq' ],
  input_assembly => 't/data/contigs.fa',
  insert_size => 250,
  scaffolder_exec => '/path/to/SSPACE.pl',
)),'Create overall iterative object');

is_deeply($iterative_scaffolding->merge_sizes, [ 90, 80, 70, 60, 50, 40, 30, 25, 20, 15, 10, 10, 10, 7, 7, 7, 5, 5, 5, 5 ], 'iteration merge sizes');
isnt($iterative_scaffolding->_intermediate_filename,'t/data/contigs.fa','Intermediate filename isnt the same as the input assembly');
ok(($iterative_scaffolding->_intermediate_filename  =~ m/contigs\.fa$/),'Intermediate filename has same base as input assembly');

done_testing();