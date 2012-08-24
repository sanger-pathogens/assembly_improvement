package Bio::AssemblyImprovement::Scaffold::SSpace::OutputFilenameRole;
use Moose::Role;
use File::Basename;
use Cwd;

has 'input_assembly'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_filename'     => ( is => 'rw', isa => 'Str', lazy     => 1, builder => '_build_output_filename' );

has '_output_prefix' => ( is => 'ro', isa => 'Str', default => "scaffolded" );

sub _build_output_filename {
    my ($self) = @_;
    my ( $filename, $directories, $suffix ) = fileparse( $self->input_assembly, qr/\.[^.]*/ );
    $directories . $filename . "." . $self->_output_prefix . $suffix;
}

no Moose;
1;

