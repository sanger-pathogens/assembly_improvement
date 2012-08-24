
=head1 NAME

Iterative   - Iteratively close gaps. Use different mappers in rotation, picking the most confident gaps first

=head1 SYNOPSIS

use Bio::AssemblyImprovement::FillGaps::GapFiller::Iterative;

my $iterative_gapfilling = Bio::AssemblyImprovement::Scaffold::SSpace::Iterative->new(
  input_files => ['abc_1.fastq', 'abc_2.fastq'],
  input_assembly => 'contigs.fa'
  insert_size => 250,
  gap_filler_exec => '/path/to/SSPACE.pl',
  merge_sizes => [100,50,30,10]
)->run;

=cut

package Bio::AssemblyImprovement::FillGaps::GapFiller::Iterative;
use Moose;
use Cwd;
use File::Basename;
use File::Copy;
use Bio::AssemblyImprovement::FillGaps::GapFiller::Main;
with 'Bio::AssemblyImprovement::Scaffold::SSpace::OutputFilenameRole';
with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';

has 'input_files'     => ( is => 'ro', isa => 'ArrayRef',      required => 1 );
has 'insert_size'     => ( is => 'ro', isa => 'Int',           required => 1 );
has 'gap_filler_exec' => ( is => 'ro', isa => 'Str',           required => 1 );
has 'mappers'         => ( is => 'ro', isa => 'ArrayRef',      lazy     => 1, builder => '_build_mappers' );
has 'merge_sizes'     => ( is => 'ro', isa => 'ArrayRef[Int]', lazy     => 1, builder => '_build_merge_sizes' );

has 'output_base_directory'  => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_base_directory' );
has '_intermediate_filename' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__intermediate_filename' );
has 'debug'                  => ( is => 'ro', isa => 'Bool', default => 0);

sub _build_output_base_directory
{
  my ($self) = @_;
  return getcwd();
}

sub final_output_filename
{
  my ($self) = @_;
  my ( $filename, $directories, $suffix ) = fileparse( $self->input_assembly, qr/\.[^.]*/ );
  return $self->output_base_directory.'/' . $filename . "." . $self->_output_prefix . $suffix; 
}

sub _build__intermediate_filename {
    my ($self) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $self->input_assembly );
    return join( '/', ( $self->_temp_directory, $filename ) );
}

sub _build_merge_sizes {
    my ($self) = @_;
    return [ 90, 70, 50, 30, 20, 10];
}

sub _build_mappers
{
  my($self) = @_;
  return ['bwa','bowtie'];
}

sub _single_scaffolding_iteration {
    my ( $self, $merge_size, $mapper ) = @_;

    my $scaffold = Bio::AssemblyImprovement::FillGaps::GapFiller::Main->new(
        input_files     => $self->input_files,
        input_assembly  => $self->_intermediate_filename,
        insert_size     => $self->insert_size,
        merge_size      => $merge_size,
        gap_filler_exec => $self->gap_filler_exec,
        debug           => $self->debug,
        mapper          => $mapper,
        _output_prefix  => $self->_output_prefix,
    )->run;
    move( $scaffold->output_filename, $self->_intermediate_filename );
    return $self;
}


sub run {
    my ($self) = @_;
    $self->output_base_directory();
    my $original_cwd = getcwd();
    chdir( $self->_temp_directory );

    copy( $self->input_assembly, $self->_intermediate_filename );

    for my $merge_size ( @{ $self->merge_sizes } ) {
        for my $mapper (@{$self->mappers})
        {
           $self->_single_scaffolding_iteration($merge_size, $mapper);
        }
    }

    chdir($original_cwd);
    move( $self->_intermediate_filename, $self->final_output_filename );
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

