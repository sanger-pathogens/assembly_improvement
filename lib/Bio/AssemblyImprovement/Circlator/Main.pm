package Bio::AssemblyImprovement::Circlator::Main;

# ABSTRACT: Wrapper around circlator

# =head1 SYNOPSIS

# =cut

use File::Spec;
use Moose;
use Cwd;
use File::Path qw( rmtree );


has 'assembly'         => ( is => 'ro', isa => 'Str', required => 1 );
has 'corrected_reads'  => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'output_directory' => ( is => 'ro', isa => 'Str', required => 0, default => "circularised" );
has 'working_directory'=> ( is => 'ro', isa => 'Str', required => 0, default => getcwd());
has 'circlator_exec'   => ( is => 'ro', isa => 'Str', required => 0, default => "/software/pathogen/external/bin/circlator");

sub run {
    my ($self) = @_;

    # remember cwd if different from working directory
    my $cwd = getcwd();
    chdir ($self->working_directory);
   
    my $cmd = join(
        ' ',
        (
            $self->circlator_exec,
            'all', 
            $self->assembly,
            $self->corrected_reads,
            $self->output_directory, # assumed that this directory does not already exist
        )
    );
	# run command
    if (system($cmd)) {
        die "Error running circlator with:\n$cmd";
    }
    #change back to cwd
    chdir ($cwd);
    
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;