
=head1 NAME

Descaffold - given a fasta file as input, output a descaffolded multi-fasta file.

=head1 SYNOPSIS

use Bio::AssemblyImprovement::Scaffold::Descaffold;

my $descaffold_obj = Bio::AssemblyImprovement::Scaffold::Descaffold->new(
  input_assembly => 'contigs.fa'
);

$descaffold_obj->run();

=cut

package Bio::AssemblyImprovement::Scaffold::Descaffold;
use Moose;
use Bio::SeqIO;

has 'input_assembly'  => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_filename' => ( is => 'ro', isa => 'Str', builder  => '_build_output_filename', lazy => 1 );
has '_output_prefix'  => ( is => 'ro', isa => 'Str', default  => "descaffolded" );

sub _build_output_filename
{
  my ($self) = @_;
  return $self->input_assembly.".".$self->_output_prefix;
}

sub run
{
  my ($self) = @_;
  
  my $fasta_obj     = Bio::SeqIO->new( -file => $self->input_assembly, -format => 'Fasta');
  my $out_fasta_obj = Bio::SeqIO->new( -file => "+>".$self->output_filename, -format => 'Fasta');
  
  while(my $seq = $fasta_obj->next_seq())
  {
    my @split_sequences = split(/N+/,$seq->seq());
    my $sequence_counter = 1;
    for my $split_sequence (@split_sequences)
    {
      next if($split_sequence eq "");
      $out_fasta_obj->write_seq(Bio::Seq->new( -display_id => $seq->display_id."_".$sequence_counter, -seq => $split_sequence ));
      $sequence_counter++;
    }
  }
  1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

