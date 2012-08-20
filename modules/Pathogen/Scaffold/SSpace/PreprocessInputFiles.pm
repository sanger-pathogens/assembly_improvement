
=head1 NAME

PreprocessInputFiles   - make sure the input files are in the correct format, and paths are resolved. This object needs to be kept in scope 
because it creates temp files which are cleaned up when it goes out of scope.

=head1 SYNOPSIS

use Pathogen::Scaffold::SSpace::PreprocessInputFiles;

my $process_input_files = Pathogen::Scaffold::SSpace::PreprocessInputFiles->new(
  input_files => ['abc_1.fastq.gz', 'abc_2.fastq'],
  input_assembly => 'contigs.fa'
);

$process_input_files->processed_input_files;
$process_input_files->processed_input_assembly;

=cut

package Pathogen::Scaffold::SSpace::PreprocessInputFiles;
use Moose;
use Cwd 'abs_path';
use File::Basename;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
with 'Pathogen::Scaffold::SSpace::TempDirectoryRole';

has 'input_assembly' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'input_files'    => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'reference'      => ( is => 'ro', isa => 'Str' );

has 'processed_input_assembly' => ( is => 'ro', isa => 'Str',        lazy => 1, builder => '_build_processed_input_assembly' );
has 'processed_input_files'    => ( is => 'ro', isa => 'ArrayRef',   lazy => 1, builder => '_build_processed_input_files' );
has 'processed_reference'      => ( is => 'ro', isa => 'Maybe[Str]', lazy => 1, builder => '_build_processed_reference' );

sub _build_processed_input_files {
    my ($self) = @_;
    my @processed_input_files;

    for my $filename ( @{ $self->input_files } ) {
        push( @processed_input_files, $self->_gunzip_file_if_needed($filename) );
    }
    return \@processed_input_files;
}

sub _build_processed_input_assembly {
    my ($self) = @_;
    return $self->_gunzip_file_if_needed($self->input_assembly);
}

sub _build_processed_reference {
    my ($self) = @_;
    return undef unless(defined($self->reference));
    return $self->_gunzip_file_if_needed($self->reference);
}

sub _gunzip_file_if_needed {
    my ( $self, $input_filename ) = @_;
    $input_filename = abs_path($input_filename);
    
    if ( $input_filename =~ /\.gz$/ ) {
        my $base_filename = fileparse( $input_filename, qr/\.[^.]*/ );
        my $output_filename = join( '/', ( $self->_temp_directory, $base_filename ) );
        gunzip $input_filename => $output_filename or die "gunzip failed: $GunzipError\n";
        return $output_filename;
    }
    else {
        return $input_filename;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

