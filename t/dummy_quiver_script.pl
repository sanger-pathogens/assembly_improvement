#!/usr/bin/env perl

my $directory_name = "tmp_quiver";

system("mkdir tmp_quiver");
system("mkdir tmp_quiver/All_output");
system("touch tmp_quiver/consensus.fasta");
system("touch tmp_quiver/aligned_reads.bam");
system("touch tmp_quiver/aligned_reads.bam.bai");
system("touch tmp_quiver/run-assembly.sh");
system("touch tmp_quiver/All_output/input.xml");
system("touch tmp_quiver/All_output/settings.xml");

# consensus.fasta, run-assembly.sh, All_output/input.xml, All_output/settings.xml

