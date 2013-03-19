package Bio::AssemblyImprovement::PrepareForSubmission::RenameContigs;

# ABSTRACT: Update the names of the contigs so that the assembly can be submitted to a database like EMBL

=head1 SYNOPSIS

Update the names of the contigs so that the assembly can be submitted to a database like EMBL

   use Bio::AssemblyImprovement::PrepareForSubmission::RenameContigs;
   
   my $obj = Bio::AssemblyImprovement::PrepareForSubmission::RenameContigs->new(
     input_assembly => 'contigs.fa',
     base_contig_name => 'ABC'
   )->run();
   

=method run

Rename the contigs

=cut

use Moose;
use File::Temp;
use Bio::SeqIO;
use File::Copy;

has 'input_assembly'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'base_contig_name' => ( is => 'ro', isa => 'Str', required => 1 );

has '_input_fh'  => ( is => 'ro', lazy => 1, builder => '_build__input_fh' );
has '_output_fh' => ( is => 'ro', lazy => 1, builder => '_build__output_fh' );

has '_temp_output_file_obj' => ( is => 'ro', lazy => 1, builder => '_build__temp_output_file_obj' );

sub _build__temp_output_file_obj {
    my ($self) = @_;
    File::Temp->new();
}

sub _build__input_fh {
    my ($self) = @_;
    Bio::SeqIO->new( -file => $self->input_assembly, -format => 'Fasta' );
}

sub _build__output_fh {
    my ($self) = @_;
    Bio::SeqIO->new( -file => "+>" . $self->_temp_output_filename, -format => 'Fasta' );
}

sub _temp_output_filename {
    my ($self) = @_;
    $self->_temp_output_file_obj->filename;
}

sub _generate_contig_name {
    my ( $self, $counter ) = @_;
    return join( '.', ( $self->base_contig_name, $counter ) );
}

sub _create_temp_outputfile {
    my ($self) = @_;
    my $seq_counter = 1;
    while ( my $input_seq = $self->_input_fh->next_seq() ) {
        $self->_output_fh->write_seq(
            Bio::Seq->new( -display_id => $self->_generate_contig_name($seq_counter), -seq => $input_seq->seq ) );
        $seq_counter++;
    }
}

sub run {
    my ($self) = @_;
    $self->_create_temp_outputfile;
    move($self->_temp_output_filename, $self->input_assembly);
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
