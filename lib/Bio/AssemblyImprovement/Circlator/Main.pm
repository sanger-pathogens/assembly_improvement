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


sub _get_number_in_filename {
	my ($self, $name) = @_;
	$name =~ /\S+\/04.merge.merge.iter.(\d+).reads.log/;
	return $1;
}

sub run {
    my ($self) = @_;

    # remember cwd if different from working directory
    my $cwd = getcwd();
    chdir ($self->working_directory);
    my $temp_dir = "tmp_circularised"; 
   
    my $cmd = join(
        ' ',
        (
            $self->circlator_exec,
            'all', 
            $self->assembly,
            $self->corrected_reads,
            $temp_dir, # assumes that this directory does not already exist
        )
    );
    
   if(system($cmd)){
    	die "Failed to run circlator with $cmd";
    	# In this case, it is OK to die. When used in the pipeline, it should stop at this point and
    	# not carry on with the rest of the steps (quiver etc)
    }
    
   if(-e $temp_dir."/06.fixstart.fasta" and -e $temp_dir."/06.fixstart.ALL_FINISHED"){
   		# rename, cat logs, clear up output
   		if(! -d $self->output_directory){
   			mkdir $self->output_directory
   		}
    	system("mv $temp_dir/00.info.txt ".$self->output_directory."/circlator.info.txt") and die "Could not move $temp_dir/00.info.txt to ".$self->output_directory."/circlator.info.txt";
    	system("mv $temp_dir/06.fixstart.fasta ".$self->output_directory."/circlator.final.fasta") and die "Could not move $temp_dir/06.fixstart.fasta to ".$self->output_directory."/circlator.final.fasta";
    	
    	my @iterative_merge_files = sort {$self->_get_number_in_filename($a) <=> $self->_get_number_in_filename($b)} glob("$temp_dir/04.merge.merge.iter.*.reads.log"); #cannot rely on glob's lexical sorting
    	
    	my @log_files = ("$temp_dir/02.bam2reads.log",
						 @iterative_merge_files,
						"$temp_dir/04.merge.merge.iterations.log",
						"$temp_dir/04.merge.merge.log",
						"$temp_dir/04.merge.circularise_details.log",
						"$temp_dir/04.merge.circularise.log",
						"$temp_dir/05.clean.log",
						"$temp_dir/06.fixstart.log");
    	
    	system("cat ".join(" ", @log_files)." > ".$self->output_directory."/circlator.log") and die "Could not cat circlator log files to ".$self->output_directory."/circlator.log";
    	system("rm -rf $temp_dir") and die "Could not delete $temp_dir"; 
    }
    
    chdir ($cwd);
    
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;