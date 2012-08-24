
=head1 NAME

Iterative   - Create the config file thats used to drive SSpace

=head1 SYNOPSIS

use Bio::AssemblyImprovement::Scaffold::SSpace::Iterative;

my $iterative_scaffolding = Bio::AssemblyImprovement::Scaffold::SSpace::Iterative->new(
  input_files => ['abc_1.fastq', 'abc_2.fastq'],
  input_assembly => 'contigs.fa'
  insert_size => 250,
  scaffolder_exec => '/path/to/SSPACE.pl',
  merge_sizes => [100,50,30,10]
)->run;

=cut

package Bio::AssemblyImprovement::Scaffold::SSpace::Iterative;
use Moose;
use Cwd;
use File::Basename;
use File::Copy;
use Bio::AssemblyImprovement::Scaffold::SSpace::Main;
with 'Bio::AssemblyImprovement::Scaffold::SSpace::OutputFilenameRole';
with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';

has 'input_files'     => ( is => 'ro', isa => 'ArrayRef',      required => 1 );
has 'insert_size'     => ( is => 'ro', isa => 'Int',           required => 1 );
has 'merge_sizes'     => ( is => 'ro', isa => 'ArrayRef[Int]', lazy     => 1, builder => '_build_merge_sizes' );
has 'scaffolder_exec' => ( is => 'ro', isa => 'Str',           required => 1 );
has 'debug'           => ( is => 'ro', isa => 'Bool', default => 0);

has 'output_base_directory'  => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_base_directory' );
has '_intermediate_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__intermediate_filename' );

sub _build_output_base_directory
{
  my ($self) = @_;
  return getcwd();
}

sub _build_merge_sizes {
    my ($self) = @_;
    return [ 90, 80, 70, 60, 50, 40, 30, 25, 20, 15, 10, 10, 7, 7, 5, 5 ];
}

sub _build__intermediate_filename {
    my ($self) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $self->input_assembly );
    return join( '/', ( $self->_temp_directory, $filename ) );
}

sub _single_scaffolding_iteration {
    my ( $self, $merge_size ) = @_;

    my $scaffold = Bio::AssemblyImprovement::Scaffold::SSpace::Main->new(
        input_files     => $self->input_files,
        input_assembly  => $self->_intermediate_filename,
        insert_size     => $self->insert_size,
        merge_size      => $merge_size,
        scaffolder_exec => $self->scaffolder_exec,
        debug           => $self->debug
    )->run;
    move( $scaffold->output_filename, $self->_intermediate_filename );
    return $self;
}

sub final_output_filename
{
  my ($self) = @_;
  my ( $filename, $directories, $suffix ) = fileparse( $self->input_assembly, qr/\.[^.]*/ );
  return $self->output_base_directory.'/' . $filename . "." . $self->_output_prefix . $suffix; 
}

sub run {
    my ($self) = @_;
    $self->output_base_directory();
    my $original_cwd = getcwd();
    chdir( $self->_temp_directory );

    copy( $self->input_assembly, $self->_intermediate_filename );

    for my $merge_size ( @{ $self->merge_sizes } ) {
        $self->_single_scaffolding_iteration($merge_size);
    }
    chdir($original_cwd);
    move( $self->_intermediate_filename, $self->final_output_filename );
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

