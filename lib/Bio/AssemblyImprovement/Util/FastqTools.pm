package Bio::AssemblyImprovement::Util::FastqTools;

# ABSTRACT: Take a fastq file and calculate some useful statistics and values

=head1 SYNOPSIS


=cut

use Moose;
use Statistics::Lite qw(:all);
#use GD::Graph::histogram;

with 'Bio::AssemblyImprovement::Util::GetReadLengthsRole';

has 'input_filename'   => ( is => 'ro', isa => 'Str' , required => 1);

# sub draw_histogram_of_read_lengths {
# 	my ($self) = @_;
# 	my $arrayref = $self->_get_read_lengths($input_filename);
# 	# Set graph details
# 	my $graph = new GD::Graph::histogram(400,600);	
# 	$graph->set( 
#                 x_label         => 'Read length',
#                 y_label         => 'Number of reads',
#                 title           => 'Histogram of read lengths for'.$input_filename,
#                 x_labels_vertical => 1,
#                 bar_spacing     => 0,
#                 shadow_depth    => 1,
#                 shadowclr       => 'dred',
#                 transparent     => 0,
#     ) 
#     or warn $graph->error;
#     #Draw the graph
#     my $gd = $graph->plot(@$arrayref) or die $graph->error;
#     #Store the graph
#     open(IMG, '>histogram.png') or die "Could not open a file called histogram.png";
#     binmode IMG;
#     print IMG $gd->png;
# 	
#   
# }

sub calculate_kmer_sizes {

	my ($self) = @_;
	my $arrayref = $self->_get_read_lengths($self->input_filename);
	my $median = median(@$arrayref);
	my $mode = mode(@$arrayref);
	my %kmer_size;
	
	$kmer_size{min} = int($median*0.66); #66% of median read length will be minimum kmer length
  	$kmer_size{max} = int($median*0.90); #90% of median read length will be maximum kmer length
  
  	if($kmer_size{min} % 2 == 0){
    	$kmer_size{min}--;
  	}
  	
  	if($kmer_size{max} % 2 == 0){
    	$kmer_size{max}--;
  	}
  	
  	return %kmer_size;
	
}

sub calculate_coverage {

	my ($self, $expected_genome_size) = @_;
	unless ($expected_genome_size) return undef;
	
	my $arrayref = $self->_get_read_lengths($self->input_filename);
	my $total_length_of_reads += $_ for @$arrayref;
	my $coverage = $total_length_of_reads/$expected_genome_size;
	$coverage = sprintf ("%.0f", $coverage);	
  	return $coverage;
	
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

