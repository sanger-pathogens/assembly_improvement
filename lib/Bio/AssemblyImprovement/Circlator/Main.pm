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
    system($cmd);

    
   if(-e $self->output_directory."/06.fixstart.fasta" and -e $self->output_directory."/06.fixstart.ALL_FINISHED"){
    	chdir ($self->output_directory);
    	# clean up, rename and cat files
    	system("mv 00.info.txt circlator.info.txt");
    	system("cat 02.bam2reads.log 04.merge.circularise.log 05.clean.log 06.fixstart.log > circlator.log");
    	my @circlator_output_to_delete = ("00.input_assembly.fasta",
    									  "00.input_assembly.fasta.fai",
    									  "01.mapreads.bam",
    									  "01.mapreads.bam.bai",
    				                      "02.bam2reads.log",
    				                      "02.bam2reads.fasta",
    				                      "03.assemble",
    				                      "04.merge.coords", #symlink
    				                      "04.merge.fasta",
    				                      "04.merge.circularise.log",
    				                      "05.clean.contigs_to_keep",
    				                      "05.clean.log",
    				                      "05.clean.coords",
    				                      "05.clean.fasta",
    				                      "05.clean.remove_small.fa",
    				                      "06.fixstart.contigs_to_not_change",
    				                      "06.fixstart.log",
    				                      );  
    	system("rm -rf ".join(" ", @circlator_output_to_delete));    	
    }
    
    chdir ($cwd);
    
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;