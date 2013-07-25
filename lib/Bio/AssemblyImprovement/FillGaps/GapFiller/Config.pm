package Bio::AssemblyImprovement::FillGaps::GapFiller::Config;

# ABSTRACT: Create the config file thats used to drive GapFiller

=head1 SYNOPSIS

Create the config file thats used to drive GapFiller.

   use Bio::AssemblyImprovement::FillGaps::GapFiller::Config;

   my $config_file_obj = Bio::AssemblyImprovement::FillGaps::GapFiller::Config->new(
     input_files => ['abc_1.fastq', 'abc_2.fastq'],
     insert_size => 250,
     mapper => 'bwa'
   )->create_config_file;
   

=method create_config_file

Create the gapfiller config file.

=head1 SEE ALSO

=for :list
* L<Bio::AssemblyImprovement::FillGaps::GapFiller::Iterative>
* L<Bio::AssemblyImprovement::FillGaps::GapFiller::Main>

=cut

use Moose;

has 'input_files'     => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'insert_size'     => ( is => 'rw', isa => 'Int',      required => 1 );
has '_default_insert_size' => ( is => 'ro', isa => 'Int',      default => 300 );
has 'mapper'          => ( is => 'ro', isa => 'Str',      default  => 'bwa' );
has 'output_filename' => ( is => 'rw', isa => 'Str',      default  => '_gap_filler.config' );

sub create_config_file {
    my ($self) = @_;
    
    if(!defined($self->insert_size) || $self->insert_size == 0 )
    {
      $self->insert_size($self->_default_insert_size);
    }

    my $input_file_names = join( ' ', @{ $self->input_files } );
    open( my $lib_fh, "+>", $self->output_filename );
    print $lib_fh "LIB ".$self->mapper ." ". $input_file_names . " " . $self->insert_size . " 0.3 FR";
    
    close($lib_fh);

    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
