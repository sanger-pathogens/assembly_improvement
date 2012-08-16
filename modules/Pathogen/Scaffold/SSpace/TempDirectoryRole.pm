package Pathogen::Scaffold::SSpace::TempDirectoryRole;
use Moose::Role;
use Cwd;
use File::Temp;

has '_temp_directory_obj' => ( is => 'ro', isa => 'Str', lazy     => 1, builder => '_build__temp_directory_obj' );
has '_temp_directory'     => ( is => 'ro', isa => 'Str', lazy     => 1, builder => '_build__temp_directory' );

sub _build__temp_directory_obj {
    my ($self) = @_;
    File::Temp->newdir( CLEANUP => 1, DIR => getcwd() );
}

sub _build__temp_directory {
    my ($self) = @_;
    $self->_temp_directory_obj->dirname();
}

no Moose;
1;
