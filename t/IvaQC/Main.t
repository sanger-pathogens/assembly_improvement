#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::IvaQC::Main');
}

my $current_dir = getcwd();

ok(my $obj = Bio::AssemblyImprovement::IvaQC::Main->new(
    'db'      			  => $current_dir.'/t/data/database',
    'forward_reads'       => $current_dir.'/t/data/forward.fastq',
    'reverse_reads'       => $current_dir.'/t/data/reverse.fastq',
    'assembly'			  => $current_dir.'/t/data/contigs.fa',
    'iva_qc_exec'         => $current_dir.'/t/dummy_iva_qc_script',
), 'initialize object');

$obj->run();

ok(-e 'iva_qc/iva_qc.stats.txt', 'iva_qc stats file OK');
ok(-e 'iva_qc/iva_qc.assembly_contigs_hit_ref.fasta', 'iva_qc fasta file OK');
ok(-e 'iva_qc/iva_qc.assembly_vs_ref.coords', 'iva_qc coords file OK');
ok(-e 'iva_qc/iva_qc.assembly_v_ref.act.sh', 'iva_qc act script OK');
ok(-e 'iva_qc/iva_qc.assembly_v_ref.blastn', 'iva_qc blastn results file OK');

unlink("iva_qc/iva_qc.stats.txt");
unlink("iva_qc/iva_qc.assembly_contigs_hit_ref.fasta");
unlink("iva_qc/iva_qc.assembly_vs_ref.coords");
unlink("iva_qc/iva_qc.assembly_v_ref.act.sh");
unlink("iva_qc/iva_qc.assembly_v_ref.blastn");

done_testing();
