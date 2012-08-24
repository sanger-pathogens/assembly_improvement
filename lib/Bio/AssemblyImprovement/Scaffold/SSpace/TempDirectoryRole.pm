package Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole;
use Moose::Role;
use Cwd;
use File::Temp;

has '_temp_directory_obj' => ( is => 'ro', isa => 'File::Temp::Dir', lazy     => 1, builder => '_build__temp_directory_obj' );
has '_temp_directory'     => ( is => 'ro', isa => 'Str', lazy     => 1, builder => '_build__temp_directory' );
has 'debug'               => ( is => 'ro', isa => 'Bool', default => 0);

sub _build__temp_directory_obj {
    my ($self) = @_;
    
    my $cleanup = 1;
    $cleanup = 0 if($self->debug == 1);
    File::Temp->newdir( CLEANUP => $cleanup , DIR => getcwd() );
}

sub _build__temp_directory {
    my ($self) = @_;
    $self->_temp_directory_obj->dirname();
}

no Moose;
1;
