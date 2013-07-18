package Bio::AssemblyImprovement::Scaffold::SSpace::PreprocessInputFiles;
# ABSTRACT: Make sure the input files are in the correct format, and paths are resolved.

=head1 SYNOPSIS

Make sure the input files are in the correct format, and paths are resolved. This object needs to be kept in scope
because it creates temp files which are cleaned up when it goes out of scope.

   use Bio::AssemblyImprovement::Scaffold::SSpace::PreprocessInputFiles;

   my $process_input_files = Bio::AssemblyImprovement::Scaffold::SSpace::PreprocessInputFiles->new(
     input_files => ['abc_1.fastq.gz', 'abc_2.fastq'],
     input_assembly => 'contigs.fa'
   );

   $process_input_files->processed_input_files;
   $process_input_files->processed_input_assembly;

=method processed_input_files

Process the input FASTQ files and return their location.

=method processed_input_assembly

Process the input FASTA file and return its location.

=cut

use Moose;
use Cwd 'abs_path';
use File::Basename;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use Bio::AssemblyImprovement::Util::FastaTools;

with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';
with 'Bio::AssemblyImprovement::Abacas::DelimiterRole';
with 'Bio::AssemblyImprovement::Util::UnzipFileIfNeededRole';

has 'input_assembly' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'input_files'    => ( is => 'ro', isa => 'Maybe[ArrayRef]');
has 'reference'      => ( is => 'ro', isa => 'Maybe[Str]' );

has 'minimum_contig_size_in_assembly'  => ( is => 'ro', isa => 'Int', default => 300 );
has 'minimum_perc_to_turn_off_filtering'  => ( is => 'ro', isa => 'Int', default => 95 );

has 'processed_input_assembly' => ( is => 'ro', isa => 'Str',        lazy => 1, builder => '_build_processed_input_assembly' );
has 'processed_input_files'    => ( is => 'ro', isa => 'Maybe[ArrayRef]',   lazy => 1, builder => '_build_processed_input_files' );
has 'processed_reference'      => ( is => 'ro', isa => 'Maybe[Str]', lazy => 1, builder => '_build_processed_reference' );



sub _build_processed_input_files {
    my ($self) = @_;
    my @processed_input_files;
    return undef unless(defined($self->input_files));

    for my $filename ( @{ $self->input_files } ) {
        push( @processed_input_files,  $self->_gunzip_file_if_needed( $filename, $self->_temp_directory) );
    }
    return \@processed_input_files;
}

sub _build_processed_input_assembly {
    my ($self) = @_;
    my $base_filename = fileparse( $self->input_assembly);
    my $output_filename = join( '/', ( $self->_temp_directory, $base_filename.'.filtered' ) );
    my $fasta_processor = Bio::AssemblyImprovement::Util::FastaTools->new(input_filename => $self->input_assembly);
    return $fasta_processor->remove_small_contigs($output_filename, $self->minimum_contig_size_in_assembly, $self->minimum_perc_to_turn_off_filtering);
}

sub _build_processed_reference {
    my ($self) = @_;
    return undef unless(defined($self->reference));
    return $self->_gunzip_file_if_needed($self->reference, $self->_temp_directory);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

