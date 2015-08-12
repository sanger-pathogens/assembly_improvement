#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use File::Path qw( rmtree );

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

my @files_exist = ('iva_qc.stats.txt',
			       'iva_qc.assembly_contigs_hit_ref.fasta',
			       'iva_qc.assembly_vs_ref.coords',
			       'iva_qc.assembly_v_ref.act.sh',
			       'iva_qc.assembly_v_ref.blastn',
			       );
			       
my @files_should_not_exist = ('out.contig_placement.R',
                              'out.reads_mapped_to_assembly.bam',
                              'out.reads_mapped_to_assembly.bam.bai',
                              'out.reads_mapped_to_assembly.bam.flagstat',
                              'out.reads_mapped_to_ref.bam',
                              'out.reads_mapped_to_ref.bam.flagstat',
                              );
my @dir_should_not_exist = ('out.gage');

foreach my $file (@files_exist){
	ok(-e "iva_qc/$file", "$file OK");
	unlink("iva_qc/$file");
}

foreach my $file(@files_should_not_exist){
	ok(! -e "iva_qc/$file", "$file should not exist OK");
}

foreach my $dir(@dir_should_not_exist){
	ok(! -d "iva_qc/$dir", "$dir should not exist OK");

}
rmtree($current_dir.'/iva_qc');

done_testing();
