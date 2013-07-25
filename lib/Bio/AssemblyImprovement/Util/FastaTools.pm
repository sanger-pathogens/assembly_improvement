package Bio::AssemblyImprovement::Util::FastaTools;

# ABSTRACT: Utilities for sequences in a FASTA file

=head1 SYNOPSIS


=cut

use Moose;
use Bio::SeqIO;
use Cwd 'abs_path';

with 'Bio::AssemblyImprovement::Util::UnzipFileIfNeededRole';
with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';

has 'input_filename'   => ( is => 'ro', isa => 'Str' , required => 1 );
has 'output_filename' => ( is => 'rw', isa => 'Str' , lazy => 1, builder => '_build_output_filename' );


sub _build_output_filename {
    my ($self) = @_;
    return join('/', ($self->_temp_directory, '_filter_by_length.fa'));
}


# Throw away small contigs, but not if the overall size of the genome drops too low
sub remove_small_contigs {
    my ($self, $minimum_contig_size_in_assembly, $minimum_perc_to_turn_off_filtering) = @_;


    my $fasta_file = $self->_gunzip_file_if_needed($self->input_filename);
    my $fasta_obj =  Bio::SeqIO->new(-file => $fasta_file, -format => 'Fasta');
    my $out_fasta_obj = Bio::SeqIO->new(-file => "+>".$self->output_filename , -format => 'Fasta');

    my $sequence_length = 0;
    my $bases_kept = 0;
    while(my $seq = $fasta_obj->next_seq()) {
        $sequence_length +=  $seq->length();
        next if($seq->length < $minimum_contig_size_in_assembly);
        $out_fasta_obj->write_seq($seq);
        $bases_kept += $seq->length();
    }

    if(($bases_kept /$sequence_length) *100 <  $minimum_perc_to_turn_off_filtering) {
        $self->output_filename($self->input_filename);
        return $self;
    }

    return $self;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

