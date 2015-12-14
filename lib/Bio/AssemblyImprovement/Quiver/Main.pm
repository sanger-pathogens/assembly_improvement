package Bio::AssemblyImprovement::Quiver::Main;

# ABSTRACT: Wrapper around the quiver call

# =head1 SYNOPSIS

# =cut

use Moose;
use File::Copy;
use File::Path qw( rmtree );
use Cwd;

has 'reference'			=> ( is => 'ro', isa => 'Str', required => 1);
has 'bax_files'			=> ( is => 'ro', isa => 'Str', required => 1);
has 'quiver_exec' 		=> ( is => 'ro', isa => 'Str', required => 0, default => '/software/pathogen/internal/prod/bin/pacbio_smrtanalysis' );
has 'threads'           => ( is => 'ro', isa => 'Int', required => 0, default => 6 ); #the quiver default is 16 which can lead to long PEND times on the farm. 6 has been enough so far
has 'memory' 			=> ( is => 'ro', isa => 'Int', required => 0, default => 8 );
has 'no_bsub'           => ( is => 'ro', isa => 'Bool', default  => 1);
has 'working_directory'=> ( is => 'ro', isa => 'Str', required => 0, default => getcwd());
has 'output_directory'	=> ( is => 'ro', isa => 'Str', default  => 'quiver');


sub run {
    my ($self) = @_;
    
    my $no_bsub_option = "";
    if ($self->no_bsub) {
    	$no_bsub_option = "--no_bsub";
    }
    
 	# remember cwd if different from working directory
    my $cwd = getcwd();
    chdir ($self->working_directory);
    my $temp_dir = "tmp_quiver"; 
    
    my $cmd = join(
        ' ',
        (
            $self->quiver_exec,
            '--threads', $self->threads,
            '--memory', $self->memory,
            $no_bsub_option,
            '--reference', $self->reference,
            'RS_Resequencing',
            $temp_dir,
            $self->bax_files,
        )
    );

    if (system($cmd)) {
        die "Error running Quiver with:\n$cmd";
    }
    if(! -e $temp_dir."/consensus.fasta"){
    	die "No consensus.fasta file. Error running Quiver with:\n$cmd";
    }
        
    # Keep some files, delete the rest
    # consensus.fasta, run-assembly.sh, All_output/input.xml, All_output/settings.xml
	if(! -d $self->output_directory){	
		mkdir $self->output_directory;
	}
	
	move (join('/', $temp_dir, 'consensus.fasta'), join('/', $self->output_directory, 'quiver.final.fasta'));
	move (join('/', $temp_dir, 'aligned_reads.bam'), join('/', $self->output_directory, 'quiver.aligned_reads.bam'));
	move (join('/', $temp_dir, 'aligned_reads.bam.bai'), join('/', $self->output_directory, 'quiver.aligned_reads.bam.bai'));
	move (join('/', $temp_dir, 'run-assembly.sh'), join('/', $self->output_directory, 'quiver.run-assembly.sh'));
	move (join('/', $temp_dir, 'All_output', 'input.xml'), join('/', $self->output_directory, 'quiver.input.xml'));
	move (join('/', $temp_dir, 'All_output', 'settings.xml'), join('/', $self->output_directory, 'quiver.settings.xml'));
    
    rmtree ($temp_dir);
    chdir ($cwd);
    # TODO: check the status of bsub.o file and if it failed because the memory was low, then resubmit with more - try twice
    
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

