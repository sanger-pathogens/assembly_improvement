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
my $prefix = 'test_iva_qc';

ok(my $obj = Bio::AssemblyImprovement::IvaQC::Main->new(
    'db'      			  => $current_dir.'/t/data/database',
    'forward_reads'       => $current_dir.'/t/data/forward.fastq',
    'reverse_reads'       => $current_dir.'/t/data/reverse.fastq',
    'assembly'			  => $current_dir.'/t/data/contigs.fa',
    'iva_qc_exec'         => $current_dir.'/t/dummy_iva_qc_script',
    'prefix'              => $prefix,
), 'initialize object');

$obj->run();

my @files_exist = ('.stats.txt',
			       '.assembly_contigs_hit_ref.fasta',
			       '.assembly_vs_ref.coords',
			       '.assembly_v_ref.act.sh',
			       '.assembly_v_ref.blastn',
			       );
			       
my @files_should_not_exist = ('.contig_placement.R',
                              '.reads_mapped_to_assembly.bam',
                              '.reads_mapped_to_assembly.bam.bai',
                              '.reads_mapped_to_assembly.bam.flagstat',
                              '.reads_mapped_to_ref.bam',
                              '.reads_mapped_to_ref.bam.flagstat',
                              );
my @dir_should_not_exist = ('.gage');

foreach my $file (@files_exist){
	ok(-e "iva_qc/$prefix$file", "$prefix$file OK");
	unlink("iva_qc/$prefix$file");
}

foreach my $file(@files_should_not_exist){
	ok(! -e "iva_qc/$prefix$file", "$prefix$file should not exist OK");
}

foreach my $dir(@dir_should_not_exist){
	ok(! -d "iva_qc/$prefix$dir", "$prefix$dir should not exist OK");

}
rmtree($current_dir.'/iva_qc');

done_testing();
