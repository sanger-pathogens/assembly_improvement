package Bio::AssemblyImprovement::Assemble::SGA::Main;
# ABSTRACT: Run SGA preprocess and error correction steps

=head1 SYNOPSIS

Runs SGA preprocess and error correction steps.

   use Bio::AssemblyImprovement::Assemble::SGA::Main;

   my $sga_error_corrector = Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads->new(
      input_filename => 'my_sga_preprocessed_data.fastq',
      algorithm      => 'ropebwt',
      threads        => 8,
      kmer_length	 => 41,
      sga_exec	     => '/path/to/sga/script.pl',
   );

   $sga_error_corrector->run();
   my $results_file = $sga_corrector->_output_filename();
   
=method run



=head1 SEE ALSO

=for :list
* L<Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads>
* L<Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads>

=cut

use Moose;
use Cwd;
use File::Copy;

use Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads;
use Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads;

with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';

has 'input_files'       => ( is => 'ro', isa => 'ArrayRef' , required => 1);
has 'algorithm'	        => ( is => 'ro', isa => 'Str',   default => 'ropebwt'); # BWT construction algorithm: sais or ropebwt
has 'threads'	        => ( is => 'ro', isa => 'Num',   default => 1); # Use this many threads for computation
has 'kmer_length'	    => ( is => 'ro', isa => 'Num',   default=> 31); # TODO: Calculate sensible default value
has 'output_filename'   => ( is => 'rw', isa => 'Str',  default  => '_sga_preprocessed_and_corrected.fastq' );
has 'output_directory'  => ( is => 'rw', isa => 'Str'				); # Default to temporary directory in current working directory. 
has 'sga_exec'          => ( is => 'rw', isa => 'Str',   required => 1 );
has 'debug'             => ( is => 'ro', isa => 'Bool',  default => 0);



sub run {
    my ($self) = @_;
    my $original_cwd = getcwd();
    
    unless (defined $self->output_directory) {
    	$self->output_directory( $self->_temp_directory );
    }
    chdir( $self->output_directory ); # Default to temporary directory if alternative not provided
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);
    
    # SGA preprocess
    my $sga_preprocessor     = Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads->new(
            input_files      => $self->input_files,
            output_directory => $self->output_directory,
            sga_exec         => $self->sga_exec,
            debug			 => $self->debug,
    );
    
	$sga_preprocessor->run();
	my $preprocessed_file  = $sga_preprocessor->_output_filename();
	
	# SGA error correction
	my $sga_error_corrector = Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads->new(
      input_filename 		=> $preprocessed_file,
      algorithm      		=> $self->algorithm,
      threads        		=> $self->threads,
      kmer_length	 		=> $self->kmer_length,
      output_filename		=> $self->output_filename, #If results needed in a file other than default
      output_directory		=> $self->output_directory,
      sga_exec	     		=> $self->sga_exec,
      debug			        => $self->debug,
    );
 
	#$sga_error_corrector->run();
	
    chdir($original_cwd);
    return $self;
}

sub _output_filename {
	my ($self) = @_;
	return join ('/', $self->output_directory, $self->output_filename);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

