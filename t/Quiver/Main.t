#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use File::Path qw( rmtree );

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Quiver::Main');
}

my $current_dir = getcwd();

ok(my $obj = Bio::AssemblyImprovement::Quiver::Main->new(
    'reference'      	  => $current_dir.'/t/data/contigs.fa',
    'bax_files'           => $current_dir.'/t/data/',
    'quiver_exec'         => $current_dir.'/t/dummy_quiver_script.pl',
), 'initialize object');

$obj->run();

my @files_exist = ('quiver.final.fasta',
				   'quiver.aligned_reads.bam',
				   'quiver.aligned_reads.bam.bai',
			       'quiver.settings.xml',
			       'quiver.run-assembly.sh',
			       'quiver.input.xml',
			       );


foreach my $file (@files_exist){
	ok(-e "quiver/$file", "$file exists OK");
}

rmtree($current_dir.'/quiver');

done_testing();
