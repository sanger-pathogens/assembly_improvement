package Bio::AssemblyImprovement::Util::OrderContigsByLength;

# ABSTRACT: Sorts a fasta file by sequence length

=head1 SYNOPSIS

$sort_contigs = Bio::AssemblyImprovement::Util::OrderContigsByLength->new( input_filename  => 'input_file.fa' );

# get/set the output filename
$sort_contigs->output_filename('my_output_file.fa');

# set rename contigs
$sort_contigs->contig_basename('scaffold');

# sort contigs
$sort_contigs->run();

=cut

use Moose;
use Bio::SeqIO;
use File::Basename;
use File::Copy;

with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';

has 'input_filename'        => ( is => 'ro', isa => 'Str',        required => 1       );
has 'contig_basename'       => ( is => 'rw', isa => 'Maybe[Str]', default => undef    );
has 'rename_contigs'        => ( is => 'rw', isa => 'Bool',       default => 1        );
has 'output_filename'       => ( is => 'rw', isa => 'Str',        lazy_build => 1     );
has '_output_prefix'        => ( is => 'ro', isa => 'Str',        default => "sorted" );
has '_temp_output_filename' => ( is => 'ro', isa => 'Str',        lazy_build => 1     );
has '_input_fh'             => ( is => 'ro', isa => 'Bio::SeqIO', lazy_build => 1     );
has '_output_fh'            => ( is => 'ro', isa => 'Bio::SeqIO', lazy_build => 1     );

sub _build_output_filename
{
    my ($self) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $self->input_filename, qr/\.[^.]*/ );
    if($suffix =~ m/^\.fa$|^\.fasta$/)
    {
        # keep fa or fasta suffix
        return $directories . $filename . "." . $self->_output_prefix . $suffix;
    }
    else 
    {
        return $directories . $filename . $suffix . "." . $self->_output_prefix;
    }
}

sub _build__temp_output_filename
{
    my ($self) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $self->input_filename, qr/\.[^.]*/ );
    return join('/',($self->_temp_directory,$filename.'.temp.fa'));
}

sub _build__input_fh 
{
    my ($self) = @_;
    return Bio::SeqIO->new( -file => $self->input_filename, -format => 'Fasta' );
}

sub _build__output_fh
{
    my ($self) = @_;
    return Bio::SeqIO->new( -file => "+>" . $self->_temp_output_filename, -format => 'Fasta' );
}

sub _rename_contig
{
    my ($self,$seq_name,$contig_number) = @_;

    if( defined $self->contig_basename )
    {
        # rename contig
        return $self->contig_basename.$contig_number;
    }
    elsif( $seq_name =~ m/^(NODE_)\d+(\D?.*)$/i )
    {
        # renumber velvet/spades contig
        return $1.$contig_number.$2;
    }
    elsif( $seq_name =~ m/^(scaffold)\d+(\D?.*)$/i )
    {
        # renumber scaffold contig
        return $1.$contig_number.$2;
    }
    else
    {
        # append contig number to contig name
        return join('.',($seq_name,$contig_number));
    }
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
    my $count = 1;
    for my $seq (@sequences)
    {
        $seq->display_id($self->_rename_contig($seq->display_id,$count)) if $self->rename_contigs;
        $self->_output_fh->write_seq( $seq );
        $count++;
    }

    # move sorted temp file to outputfile
    move($self->_temp_output_filename, $self->output_filename);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
