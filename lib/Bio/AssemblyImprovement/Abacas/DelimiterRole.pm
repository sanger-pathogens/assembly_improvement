package Bio::AssemblyImprovement::Abacas::DelimiterRole;
use Moose::Role;
use Bio::SeqIO;
use File::Basename;

sub _sequence_delimiter
{
  my ($self, $filename) = @_;
  my $spacer = "";
  for (1..100){ $spacer.="NNNNNNNNNN"; }
  for (1..500) { $spacer.="GGGGGGGGGG"; }
  for (1..100){ $spacer.="NNNNNNNNNN"; }
  return $spacer;
}

sub _count_sequences
{
  my ($self, $filename) = @_;
  my $fasta_obj =  Bio::SeqIO->new( -file => $filename , -format => 'Fasta');
  my $seq_counter = 0;
  while(my $seq = $fasta_obj->next_seq())
  {
    $seq_counter++;
  }
  return $seq_counter;
}

sub _merge_contigs_into_one_sequence
{
  my ($self, $filename) = @_;
  return $filename if($self->_count_sequences($filename) == 1);
  my ( $base_filename, $directories, $suffix ) = fileparse(  $filename );
  
  my $output_filename =  $self->_temp_directory.'/'.$base_filename.".union.fa";
  my $fasta_obj =  Bio::SeqIO->new( -file => $filename , -format => 'Fasta');
  my $out_fasta_obj = Bio::SeqIO->new(-file => "+>".$output_filename , -format => 'Fasta');
  
  my $concat_sequence = "";
  my $seq_counter = 0;
  my $sequence_delimiter = $self->_sequence_delimiter;
  while(my $seq = $fasta_obj->next_seq())
  {
    if($seq_counter == 0)
    {
      $concat_sequence = $seq->seq();
    }
    else
    {
      $concat_sequence = $concat_sequence. $sequence_delimiter . $seq->seq();
    }
    $seq_counter++;
  }  
  
  $out_fasta_obj->write_seq(Bio::Seq->new( -display_id => 'union_of_contigs_with_delimiters', -seq => $concat_sequence));
  return $output_filename;
}

sub _split_sequence_on_delimiter
{
  my ($self, $filename) = @_;
  
  my $output_filename = $filename.".split.fa";
  
  my $fasta_obj =  Bio::SeqIO->new( -file => $filename , -format => 'Fasta');
  my $out_fasta_obj = Bio::SeqIO->new(-file => "+>".$output_filename , -format => 'Fasta');
  my $sequence_counter = 0; 
  my $sequence_delimiter = $self->_sequence_delimiter;
  while(my $seq = $fasta_obj->next_seq())
  {
    my @split_sequences = split(/$sequence_delimiter/,  $seq->seq());
    for my $split_sequence (@split_sequences)
    {
      $out_fasta_obj->write_seq(Bio::Seq->new( -display_id => 'contig_'.$sequence_counter, -seq => $split_sequence));
      $sequence_counter++;
    }
  }
  return $output_filename;
}


no Moose;
1;
