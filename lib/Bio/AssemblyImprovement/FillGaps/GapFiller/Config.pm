
=head1 NAME

Config   - Create the config file thats used to drive GapFiller

=head1 SYNOPSIS

use Bio::AssemblyImprovement::FillGaps::GapFiller::Config;

my $config_file_obj = Bio::AssemblyImprovement::FillGaps::GapFiller::Config->new(
  input_files => ['abc_1.fastq', 'abc_2.fastq'],
  insert_size => 250,
  mapper => 'bwa'
)->create_config_file;

=cut

package Bio::AssemblyImprovement::FillGaps::GapFiller::Config;
use Moose;

has 'input_files'     => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'insert_size'     => ( is => 'ro', isa => 'Int',      required => 1 );
has 'mapper'          => ( is => 'ro', isa => 'Str',      default  => 'bwa' );
has 'output_filename' => ( is => 'rw', isa => 'Str',      default  => '_gap_filler.config' );

sub create_config_file {
    my ($self) = @_;

    my $input_file_names = join( ' ', @{ $self->input_files } );
    open( my $lib_fh, "+>", $self->output_filename );
    print $lib_fh "LIB ".$self->mapper ." ". $input_file_names . " " . $self->insert_size . " 0.3 FR";
    
    close($lib_fh);

    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
