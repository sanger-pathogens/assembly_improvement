#!/usr/bin/env perl

my $command = shift;
if($command eq 'preprocess'){
	system("touch _sga_preprocessed.fastq");
}elsif ($command eq 'index'){
	system("touch _sga_preprocessed.bwt");
	system("touch _sga_preprocessed.sai");
}elsif ($command eq 'correct'){
	system("touch _sga_error_corrected.fastq");
}
	
