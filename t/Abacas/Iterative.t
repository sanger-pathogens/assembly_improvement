#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use Cwd 'abs_path';
use File::Path qw(make_path remove_tree);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Abacas::Iterative');
}

my $cwd = getcwd();
ok((my $abacas_obj = Bio::AssemblyImprovement::Abacas::Iterative->new(
  input_assembly => 't/data/contigs.fa',
  reference      => 't/data/my_reference.fa',
  abacas_exec => $cwd.'/t/dummy_abacas_script.pl',
  minimum_perc_to_keep => 0,
  debug  => 0
)),'Create overall main object');

ok($abacas_obj->run, 'Run the scaffolder with a dummy script');
is(10, $abacas_obj->_count_genomic_bases('t/data/contigs_with_Ns.fa'),'Count the bases excluding N');

unlink('contigs.scaffolded.fa');
done_testing();