
=head1 NAME

Iterative   - Iteratively run abacas to order contigs

=head1 SYNOPSIS

use Bio::AssemblyImprovement::Abacas::Iterative;

my $iterative_contig_ordering = Bio::AssemblyImprovement::Abacas::Iterative->new(
  reference   => 'reference.fa'
  input_assembly => 'contigs.fa'
  abacas_exec => 'abacas.pl'
)->run();

=cut

package Bio::AssemblyImprovement::Abacas::Iterative;
use Moose;
use Bio::SeqIO;
use Cwd;
use Bio::AssemblyImprovement::Abacas::Main;

has 'reference'       => ( is => 'rw', isa => 'Str',  required => 1 );
has 'abacas_exec'     => ( is => 'rw', isa => 'Str',  default  => 'abacas.pl' );
has 'debug'           => ( is => 'ro', isa => 'Bool', default  => 0 );
has 'minimum_perc_to_keep'  => ( is => 'ro', isa => 'Int', default => 95 );

has 'output_base_directory'  => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_base_directory' );
with 'Bio::AssemblyImprovement::Scaffold::SSpace::OutputFilenameRole';
with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';

sub _build_output_base_directory
{
  my ($self) = @_;
  return getcwd();
}


sub _count_genomic_bases
{
  my ($self, $filename) = @_;
  my $genomic_bases_counter = 0;
  my $fasta_obj =  Bio::SeqIO->new( -file => $filename , -format => 'Fasta');
  while(my $seq = $fasta_obj->next_seq())
  {
    $_ = $seq->seq();
    my $number = $_ =~ s/[ACGT]//gi;
    $genomic_bases_counter += $number ;
  }
  
  return $genomic_bases_counter;
}

sub run
{
  my($self) = @_;
  
  my $original_base_count = $self->_count_genomic_bases($self->input_assembly);
  my $nucmer_filename = $self->_run_abacas('nucmer');

  if( ($self->_count_genomic_bases($nucmer_filename )*100)/$original_base_count >=  $self->minimum_perc_to_keep)
  {
    return $nucmer_filename->final_output_filename ;
  }

  my $promer_filename = $self->_run_abacas('promer');
  if( ($self->_count_genomic_bases($promer_filename )*100)/$original_base_count >=  $self->minimum_perc_to_keep)
  {
    return $promer_filename->final_output_filename ;
  }
  
  return $self->input_assembly;
}

sub _run_abacas
{
  my($self, $mode) = @_;
  my $scaffolding_obj = Bio::AssemblyImprovement::Abacas::Main->new(
    reference      => $self->reference,
    input_assembly => $self->input_assembly,
    abacas_exec    => $self->abacas_exec,
    debug          => $self->debug,
    output_base_directory => $self->output_base_directory,
    mode           => $mode
    
  );
  $scaffolding_obj->run(); 
  return $scaffolding_obj->final_output_filename;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

