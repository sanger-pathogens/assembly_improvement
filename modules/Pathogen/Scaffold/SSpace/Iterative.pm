
=head1 NAME

Iterative   - Create the config file thats used to drive SSpace

=head1 SYNOPSIS

use Pathogen::Scaffold::SSpace::Iterative;

my $iterative_scaffolding = Pathogen::Scaffold::SSpace::Iterative->new(
  input_files => ['abc_1.fastq', 'abc_2.fastq'],
  input_assembly => 'contigs.fa'
  insert_size => 250,
  scaffolder_exec => '/path/to/SSPACE.pl',
  merge_sizes => [100,50,30,10]
)->run;

=cut

package Pathogen::Scaffold::SSpace::Iterative;
use Moose;
use Cwd;
use File::Basename;
use File::Copy;
use Pathogen::Scaffold::SSpace::Main;
with 'Pathogen::Scaffold::SSpace::OutputFilenameRole';
with 'Pathogen::Scaffold::SSpace::TempDirectoryRole';

has 'input_files'     => ( is => 'ro', isa => 'ArrayRef',      required => 1 );
has 'insert_size'     => ( is => 'ro', isa => 'Int',           required => 1 );
has 'merge_sizes'     => ( is => 'ro', isa => 'ArrayRef[Int]', lazy     => 1, builder => '_build_merge_sizes' );
has 'scaffolder_exec' => ( is => 'ro', isa => 'Str',           required => 1 );

has '_intermediate_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__intermediate_filename' );

sub _build_merge_sizes {
    my ($self) = @_;
    return [ 90, 80, 70, 60, 50, 40, 30, 25, 20, 15, 10, 10, 10, 7, 7, 7, 5, 5, 5, 5 ];
}

sub _build__intermediate_filename {
    my ($self) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $self->input_assembly );
    return join( '/', ( $self->_temp_directory, $filename ) );
}

sub _single_scaffolding_iteration {
    my ( $self, $merge_size ) = @_;

    my $scaffold = Pathogen::Scaffold::SSpace::Main->new(
        input_files     => $self->input_files,
        input_assembly  => $self->_intermediate_filename,
        insert_size     => $self->insert_size,
        merge_size      => $merge_size,
        scaffolder_exec => $self->scaffolder_exec
    )->run;
    move( $scaffold->output_filename, $self->_intermediate_filename );
    return $self;
}

sub run {
    my ($self) = @_;

    my $original_cwd = getcwd();
    chdir( $self->_temp_directory );

    copy( $self->input_assembly, $self->_intermediate_filename );

    for my $merge_size ( @{ $self->merge_sizes } ) {
        $self->_single_scaffolding_iteration($merge_size);
    }

    move( $self->_intermediate_filename, $self->_scaffolded_filename );

    chdir($original_cwd);
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

