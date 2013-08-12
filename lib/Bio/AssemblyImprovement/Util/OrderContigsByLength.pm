package Bio::AssemblyImprovement::Util::OrderContigsByLength;

# ABSTRACT: Sorts a fasta file by sequence length

=head1 SYNOPSIS
$sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => 'input_file.fa', 
                                                                           output_filename => 'output_file.fa' );
$sort_contigs->run();

Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => 'input_file.fa' )->run();

=cut

use Moose;
use Bio::SeqIO;
use File::Temp;
use File::Copy;

has 'input_filename'    => ( is => 'ro', isa => 'Str',        required   => 1    );
has 'output_filename'   => ( is => 'rw', isa => 'Maybe[Str]', default    => undef );
has '_input_fh'         => ( is => 'ro', isa => 'Bio::SeqIO', lazy_build => 1    );
has '_output_fh'        => ( is => 'ro', isa => 'Bio::SeqIO', lazy_build => 1    );
has '_temp_output_file' => ( is => 'ro', isa => 'File::Temp', lazy_build => 1    );

sub _build__temp_output_file
{
    my ($self) = @_;
    return File::Temp->new( TEMPLATE => 'contig_XXXXXX', SUFFIX => '.fa');
}

sub _build__input_fh {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => $self->input_filename, -format => 'Fasta' );
}

sub _build__output_fh {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => "+>" . $self->_temp_output_file->filename, -format => 'Fasta' );
}

sub run
{
    my ($self) = @_;
    
    # get sequences
    my @sequences;
    while( my $seq = $self->_input_fh->next_seq() )
    {
        push @sequences, $seq;
    }
    
    # sort sequences
    @sequences = sort {$b->length <=> $a->length} @sequences;
    
    # write to temp file
    for my $seq (@sequences)
    {
        $self->_output_fh->write_seq( $seq );
    }

    # copy sorted temp file to outputfile 
    $self->output_filename($self->input_filename) unless defined $self->output_filename();
    copy($self->_temp_output_file->filename, $self->output_filename);
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
