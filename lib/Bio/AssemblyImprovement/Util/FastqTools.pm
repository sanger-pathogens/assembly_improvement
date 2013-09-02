package Bio::AssemblyImprovement::Util::FastqTools;

# ABSTRACT: Take a fastq file and calculate some useful statistics and values

=head1 SYNOPSIS


=cut

use Moose;
use Statistics::Lite qw(:all);
use Cwd;
use Cwd 'abs_path';
use File::Basename;
#use GD::Graph::histogram;
use Bio::SeqIO;

with 'Bio::AssemblyImprovement::Util::GetReadLengthsRole';
with 'Bio::AssemblyImprovement::Util::ZipFileRole';
with 'Bio::AssemblyImprovement::Util::UnzipFileIfNeededRole';

has 'input_filename'   => ( is => 'ro', isa => 'Str' , required => 1 );
has 'single_cell'      => ( is => 'ro', isa => 'Bool', default => 0);


# sub draw_histogram_of_read_lengths {
# 	my ($self) = @_;
#
# 	my $fastq_file = $self->_gunzip_file_if_needed( $self->input_filename );
#
# 	my $arrayref = $self->_get_read_lengths($fastq_file);
#
# 	# Set graph details
# 	my $graph = new GD::Graph::histogram(400,600);
# 	$graph->set(
#                 x_label         => 'Read length',
#                 y_label         => 'Number of reads',
#                 title           => 'Histogram of read lengths for '.$self->input_filename,
#                 x_labels_vertical => 1,
#                 bar_spacing     => 0,
#                 shadow_depth    => 1,
#                 shadowclr       => 'dred',
#                 transparent     => 0,
#     )
#     or warn $graph->error;
#     #Draw the graph
#     my $gd = $graph->plot($arrayref) or die $graph->error;
#     #Store the graph
#     open(IMG, '>histogram.png') or die "Could not open a file called histogram.png";
#     binmode IMG;
#     print IMG $gd->png;
#
#     $self->_cleaup_after_ourselves($fastq_file);
#
#
# }

sub calculate_kmer_sizes {

	my ($self) = @_;
    my %kmer_size;
	
    if ($self->single_cell) {
        my $read_length = $self->first_read_length();
        $kmer_size{min} = int($read_length * 0.5);
        $kmer_size{max} = int($read_length * 0.95);
    }
    else {
        my $fastq_file = $self->_gunzip_file_if_needed( $self->input_filename );

        my $arrayref = $self->_get_read_lengths($fastq_file);
        my $median = median(@$arrayref);

        # Set a minimum median so that the min kmer length stays at a reasonable value
        if($median < 30){
            $median = 30;
        }

        $kmer_size{min} = int($median*0.66); #66% of median read length will be minimum kmer length
        $kmer_size{max} = int($median*0.90); #90% of median read length will be maximum kmer length

        $self->_cleaup_after_ourselves($fastq_file);
    }

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
	unless ($expected_genome_size) { return undef };
	
	my $fastq_file = $self->_gunzip_file_if_needed( $self->input_filename );
	
	my $arrayref = $self->_get_read_lengths($fastq_file);
	my $total_length_of_reads = 0;
	$total_length_of_reads += $_ for @$arrayref;
	my $coverage = $total_length_of_reads/$expected_genome_size;
	$coverage = sprintf ("%.0f", $coverage);	# Rounding it up
	
	$self->_cleaup_after_ourselves($fastq_file);
  	
  	return $coverage;
	
}

# If the reads are ordered as /1, /2, /1, /2...this subroutine will split them
# into two separate files
sub split_fastq {

	my ($self, $outfile_forward, $outfile_reverse) = @_;

	my $fastq_file = $self->_gunzip_file_if_needed( $self->input_filename );
	my $fastq_obj =  Bio::SeqIO->new( -file => $fastq_file , -format => 'Fastq' );
	
	$outfile_forward ||= 'forward.fastq';
	$outfile_reverse ||= 'reverse.fastq';
		
	my $forward_fastq = Bio::SeqIO->new( -file => ">$outfile_forward" , -format => 'Fastq' );
	my $reverse_fastq = Bio::SeqIO->new( -file => ">$outfile_reverse" , -format => 'Fastq' );

    while(my $seq = $fastq_obj->next_seq()){
		# Example ID: @IL9_4021:8:1:8:1892#7/1
    	if($seq->id() =~ m/\/1$/ ){
    		$forward_fastq->write_seq($seq);
    	}else{
    		$reverse_fastq->write_seq($seq);
    	
    	}
    }

	$self->_cleaup_after_ourselves($fastq_file);
  	
	return $outfile_forward;
}


sub _cleaup_after_ourselves {

	my ($self, $fastq_file) = @_;
	if($fastq_file ne abs_path($self->input_filename)){ #Which means we unzipped it
  		unlink($fastq_file);
  	}
	

}


# Returns the length of the first read in the file
sub first_read_length {
    my ($self) = @_;
    my $fastq_obj;

    if ( $self->input_filename =~ /\.fq$/ || $self->input_filename =~ /\.fastq$/  ) {
    	$fastq_obj =  Bio::SeqIO->new( -file => $self->input_filename , -format => 'Fastq');
    }
    elsif ( $self->input_filename =~ /\.fq\.gz$/ || $self->input_filename =~ /\.fastq\.gz$/  ) {
    	$fastq_obj =  Bio::SeqIO->new( -file => "gunzip -c " . $self->input_filename . " |" , -format => 'Fastq');
    }
    else {
        die "File '$self->input_filename' not recognised as fastq. Needs to end in .fastq[.gz] or .fq[.gz]";
    }

    my $seq = $fastq_obj->next_seq();
    return length($seq->seq());
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

