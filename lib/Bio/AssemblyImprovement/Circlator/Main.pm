package Bio::AssemblyImprovement::Circlator::Main;

# ABSTRACT: Wrapper around circlator

# =head1 SYNOPSIS

# =cut

use File::Spec;
use Moose;
use Cwd;
use File::Path qw(make_path remove_tree);

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
		remove_tree($temp_dir) if(-d $temp_dir);
		remove_tree($self->output_directory) if(-d $self->output_directory);
   
    my $cmd = join(
        ' ',
        (
            $self->circlator_exec,
            'all', 
            $self->assembly,
            $self->corrected_reads,
            $temp_dir,
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
   			make_path($self->output_directory);
   		}
    	system("mv $temp_dir/00.info.txt ".$self->output_directory."/circlator.info.txt") and warn "Could not move $temp_dir/00.info.txt to ".$self->output_directory."/circlator.info.txt";
    	system("mv $temp_dir/06.fixstart.fasta ".$self->output_directory."/circlator.final.fasta") and die "Could not move $temp_dir/06.fixstart.fasta to ".$self->output_directory."/circlator.final.fasta";
    	
    	my @iterative_merge_files = sort {$self->_get_number_in_filename($a) <=> $self->_get_number_in_filename($b)} glob("$temp_dir/04.merge.merge.iter.*.reads.log"); #cannot rely on glob's lexical sorting
    	
    	my @log_files = ("$temp_dir/02.bam2reads.log",
						   @iterative_merge_files,
						   "$temp_dir/04.merge.merge.iterations.log",
						   "$temp_dir/04.merge.merge.log",
							 "$temp_dir/04.merge.circularise_details.log",
						   "$temp_dir/04.merge.circularise.log",
						   "$temp_dir/05.clean.log",
						   "$temp_dir/06.fixstart.log",
						  );
    	my $filtered_log_files = $self->_filter_out_non_existant_files(\@log_files);
    	system("cat ".join(" ", @{$filtered_log_files})." > ".$self->output_directory."/circlator.log") and warn "Could not cat circlator log files to ".$self->output_directory."/circlator.log";

			remove_tree($temp_dir) if(-d $temp_dir);
    }
    
    chdir ($cwd);
}

sub _filter_out_non_existant_files
{
    my($self, $files) = @_;
    my @filtered_files;
    for my $file(@{$files})
    {
        push(@filtered_files, $file) if(-e $file);
    }
    return \@filtered_files;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;