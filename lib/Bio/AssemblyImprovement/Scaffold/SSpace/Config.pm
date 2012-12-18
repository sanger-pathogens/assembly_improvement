package Bio::AssemblyImprovement::Scaffold::SSpace::Config;
# ABSTRACT: Create the config file thats used to drive SSpace

=head1 SYNOPSIS

Create the config file thats used to drive SSpace

   use Bio::AssemblyImprovement::Scaffold::SSpace::Config;

   my $config_file_obj = Bio::AssemblyImprovement::Scaffold::SSpace::Config->new(
     input_files => ['abc_1.fastq', 'abc_2.fastq'],
     insert_size => 250
   )->create_config_file;
   
=method create_config_file

Create a config file for SSpace.

=head1 SEE ALSO

=for :list
* L<Bio::AssemblyImprovement::Scaffold::SSpace::Iterative>
* L<Bio::AssemblyImprovement::Scaffold::SSpace::Main>

=cut

use Moose;

has 'input_files'     => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'insert_size'     => ( is => 'ro', isa => 'Int',      required => 1 );
has 'output_filename' => ( is => 'rw', isa => 'Str',      default  => '_scaffolder.config' );

sub create_config_file {
    my ($self) = @_;

    my $input_file_names = join( ' ', @{ $self->input_files } );
    open( my $lib_fh, "+>", $self->output_filename );
    print $lib_fh "LIB " . $input_file_names . " " . $self->insert_size . " 0.3 FR";
    close($lib_fh);

    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
