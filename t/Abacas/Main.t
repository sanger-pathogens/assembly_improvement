#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;

BEGIN { unshift( @INC, './modules' ) }

BEGIN {
    use Test::Most;
    use_ok('Pathogen::Abacas::Main');
}

my $cwd = getcwd();
ok((my $abacas_obj = Pathogen::Abacas::Main->new(
  input_assembly => 't/data/contigs.fa',
  reference      => 't/data/my_reference.fa',
  abacas_exec => $cwd.'/t/dummy_abacas_script.pl',
  debug  => 0
)),'Create overall main object');

isnt($abacas_obj->_intermediate_file_name,'t/data/contigs.fa','Intermediate filename isnt the same as the input assembly');
ok(($abacas_obj->_intermediate_file_name  =~ m/^contigs\.fa_my_reference\.fa\.fasta$/),'Intermediate filename has same base as input assembly');

ok($abacas_obj->run, 'Run the scaffolder with a dummy script');

is($abacas_obj->final_output_filename, $cwd.'/contigs.scaffolded.fa', 'final scaffolded filename');
ok((-e $abacas_obj->final_output_filename),'Scaffolding file exists in expected location');

unlink('contigs.scaffolded.fa');
done_testing();