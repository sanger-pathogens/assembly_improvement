#!/usr/bin/env perl
package Bio::AssemblyImprovement::Bin::FastqTools;
# ABSTRACT: 
# PODNAME: fastq_tools
=head1 SYNOPSIS


=cut


BEGIN { unshift( @INC, '../lib' ) }
use lib "/software/pathogen/internal/prod/lib";
use Moose;
use Getopt::Long;
use Switch;


use Bio::AssemblyImprovement::Util::FastqTools;

my ( $input_file, $task, $genome_size, $help);


GetOptions(
    'i|input_file=s'        => \$input_file,
    't|task'                => \$task,
    'g|genome_size'		    => \$genome_size,
    'h|help'                => \$help,
);


( defined($input_file)  && !$help ) or die <<USAGE;
Usage: fastq_tools [options]
	
        -i|input_file          <fastq file>
        -h|histogram           <draw and save a histogram of the read lengths >
        -k|kmer				   <calculate kmer sizes>
        -c|coverage			   <coverage>
  
        -h|help      		   <this message>

USAGE

my $fastq_processor  = Bio::AssemblyImprovement::Util::FastqTools->new(
    input_filename   => $input_file, 
);

switch ($task) {

	#Draws and saves a histogram of the read lengths in a file called histogram.png in the current working directory
	case "histogram"    { 
						  $fastq_processor->draw_histogram_of_read_lengths(); 
						}
						
	case "kmer"			{
						  my %kmer_sizes = $fastq_processor->calculate_kmer_sizes();
						  print "Minimum kmer size: $kmer_sizes{min} \n Maximum kmer size: $kmer_sizes{max} \n";
						}
	case "coverage"		{
						  my $coverage = $fastq_processor->calculate_coverage($genome_size);
						  print "Coverage is $coverage x \n"; 
						 }
						 
	else				{ print "Task $task not recognised. Type fastq_tools -h for help." }
}
							
		
