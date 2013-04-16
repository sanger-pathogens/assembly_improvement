package Bio::AssemblyImprovement::Assemble::SGA::Main;
# ABSTRACT: Run SGA preprocess and error correction steps

=head1 SYNOPSIS

Runs SGA preprocess and error correction steps. Final results file made available in current working directory.
Intermediate files produced are cleaned up.

   use Bio::AssemblyImprovement::Assemble::SGA::Main;

   my $sga = Bio::AssemblyImprovement::Assemble::SGA::Main->new(
            input_files     => [ $current_dir.'/t/data/forward.fastq', $current_dir.'/t/data/reverse.fastq' ] ,
            algorithm      	=> 'ropebwt',
      		threads         => 8,
      		kmer_length	    => 40,
            sga_exec        => $current_dir.'/t/dummy_sga_script.pl',
   );
   $sga->run();
   my $results = $self->_final_results_file;
  
=method run



=head1 SEE ALSO

=for :list
* L<Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads>
* L<Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads>

=cut

use Moose;
use Cwd;
use Cwd 'abs_path';
use File::Copy;
use File::Basename;

use Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads;
use Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads;

with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';
with 'Bio::AssemblyImprovement::Util::ZipFileRole';

has 'input_files'       => ( is => 'ro', isa => 'ArrayRef' , required => 1);

# Parameters for preprocessing
has 'min_length'	   => ( is => 'ro', isa => 'Num', default => 51);
#has 'quality_filter'   => ( is => 'ro', isa => 'Num', default => 3);
has 'quality_trim'	   => ( is => 'ro', isa => 'Num', default => 3);
has 'pe_mode'		   => ( is => 'ro', isa => 'Num', default => 2); #We set default to 2 as the pipeline will almost always send in an interleaved fastq file

# Parameters for indexing and correction
has 'algorithm'	        => ( is => 'ro', isa => 'Str',   default => 'ropebwt'); # BWT construction algorithm: sais or ropebwt
has 'threads'	        => ( is => 'ro', isa => 'Num',   default => 1); # Use this many threads for computation
has 'kmer_threshold'	=> ( is => 'ro', isa => 'Num',   default=> 5); # Attempt to correct kmers that are seen less than this many times
has 'kmer_length'	    => ( is => 'ro', isa => 'Num',   default=> 41); # TODO: Calculate sensible default value
has 'output_filename'   => ( is => 'rw', isa => 'Str',  default  => '_sga_error_corrected.fastq' );
has 'output_directory'  => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build_output_directory' ); # Default to cwd
has 'sga_exec'          => ( is => 'rw', isa => 'Str',   required => 1 );
has 'debug'             => ( is => 'ro', isa => 'Bool',  default => 0);

sub _build_output_directory{
  my ($self) = @_;
  return getcwd();
}

sub _final_results_file {
	my ($self) = @_;
	return $self->output_directory.'/'.$self->output_filename;
}

# Intermediate preprocessed file
sub _intermediate_file {
	my ($self) = @_;
	return $self->_temp_directory.'/_sga_preprocessed.fastq';
}

sub run {
    my ($self) = @_;
    my $original_cwd = getcwd();
    $self->output_directory; # Essentially setting output directory to cwd
    
    # Do all the intermediate steps in a temporary directory (which will be cleaned up when object out of scope)
    chdir( $self->_temp_directory ); # Default to temporary directory if alternative not provided
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);
  
    # SGA preprocess
    my $sga_preprocessor     = Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads->new(
            input_files      => $self->input_files,
            min_length	     => $self->min_length,
            pe_mode	  		 => $self->pe_mode,
            quality_trim	 => $self->quality_trim,
            output_directory => $self->output_directory,
            sga_exec         => $self->sga_exec,
            debug			 => $self->debug,
    );
    
	$sga_preprocessor->run();
	
	# Move preprocessed file to this temporary directory
	move ( $sga_preprocessor->_output_filename(), $self->_intermediate_file  );
	
	# SGA error correction (on the results from above)
	my $sga_error_corrector = Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads->new(
      input_filename 		=> $self->_intermediate_file,
      algorithm      		=> $self->algorithm,
      threads        		=> $self->threads,
      kmer_threshold		=> $self->kmer_threshold,
      kmer_length	 		=> $self->kmer_length,
      sga_exec	     		=> $self->sga_exec,
      debug			        => $self->debug,
    );
 
	$sga_error_corrector->run();
	
	chdir($original_cwd);
	
	# Move the results file from temporary directory to the original cwd and zip it. 
	if(-e $sga_error_corrector->_output_filename){
		move ( $sga_error_corrector->_output_filename, $self->_final_results_file);
		$self->_zip_file(  $self->_final_results_file, $self->output_directory );
	}
	

    
    return $self;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

