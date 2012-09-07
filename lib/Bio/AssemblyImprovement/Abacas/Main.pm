
=head1 NAME

Bio::AssemblyImprovement::Abacas::Main   - Wrapper script for Abacas, just runs it in a separate directory.

=head1 SYNOPSIS

use Bio::AssemblyImprovement::Abacas::Main;

my $config_file_obj = Bio::AssemblyImprovement::Abacas::Main->new(
  reference   => 'reference.fa'
  input_assembly => 'contigs.fa'
  abacas_exec => 'abacas.pl'
)->run;

=cut

package Bio::AssemblyImprovement::Abacas::Main;
use Moose;
use Cwd;
use File::Copy;
use File::Basename;

with 'Bio::AssemblyImprovement::Scaffold::SSpace::OutputFilenameRole';
with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';
with 'Bio::AssemblyImprovement::Abacas::DelimiterRole';

has 'reference'       => ( is => 'rw', isa => 'Str',  required => 1 );
has 'abacas_exec'     => ( is => 'rw', isa => 'Str',  default  => 'abacas.pl' );
has 'debug'           => ( is => 'ro', isa => 'Bool', default  => 0 );
has 'mode'            => ( is => 'ro', isa => 'Str',  default  => 'nucmer' );
has 'output_base_directory'  => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_base_directory' );

sub _build_output_base_directory
{
  my ($self) = @_;
  return getcwd();
}

sub _intermediate_file_name {
    my ($self) = @_;
    
    my $input_assembly_filename = fileparse( $self->input_assembly);
    my $reference_filename = fileparse( $self->reference);
    $input_assembly_filename.'_'.$reference_filename.'.fasta';
    return join( '/', ( $self->_temp_directory, $input_assembly_filename.'_'.$reference_filename.'.fasta' ) );
}

sub final_output_filename
{
  my ($self) = @_;
  my ( $filename, $directories, $suffix ) = fileparse( $self->input_assembly, qr/\.[^.]*/ );
  return $self->output_base_directory.'/' . $filename . "." . $self->_output_prefix . $suffix; 
}


sub run {
    my ($self) = @_;
    
    my $merged_reference  = $self->_merge_contigs_into_one_sequence($self->reference);
    $self->reference($merged_reference);
    
    $self->output_base_directory();
    my $original_cwd = getcwd();
    chdir( $self->_temp_directory );
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);

    system(
        join(
            ' ',
            (
                $self->abacas_exec, 
                '-r', $self->reference,
                '-q', $self->input_assembly, 
                '-p', $self->mode, 
                $stdout_of_program
            )
        )
    );
    chdir($original_cwd);
    
    # Not implemented properly yet in "split2Multifasta.pl" as part of PAGIT
    my $split_sequence = $self->_split_sequence_on_delimiter($self->_intermediate_file_name);
    move( $split_sequence, $self->final_output_filename );
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

