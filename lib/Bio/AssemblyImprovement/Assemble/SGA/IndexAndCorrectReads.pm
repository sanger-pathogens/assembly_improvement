package Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads;

# ABSTRACT: Performs SGA error correction on the reads 

=head1 SYNOPSIS

Runs SGA index and correct. Results file (by default called _sga_error_corrected.fastq) and intermediate files
placed in a temporary directory. This temporary directory is cleaned up when this object goes out of scope.
Any script/module wishing to use the results should copy them into a more permanent location.

   use Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads;

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

Run the SGA index and correct commands with the appropriate parameters.

=method _output_filename

Return the full path to the results file


=cut

use Moose;
use Cwd 'abs_path';
use Cwd;
use File::Basename;

with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';
with 'Bio::AssemblyImprovement::Util::UnzipFileIfNeededRole';
with 'Bio::AssemblyImprovement::Util::ZipFileRole';

has 'input_filename'    => ( is => 'ro', isa => 'Str',   required => 1);
has 'algorithm'	        => ( is => 'ro', isa => 'Str',   default => 'sais'); # BWT construction algorithm: sais or ropebwt
has 'threads'	        => ( is => 'ro', isa => 'Num',   default => 1); # Use this many threads for computation
has 'disk'				=> ( is => 'ro', isa => 'Num', default => 1000000); # suffix array??
has 'kmer_threshold'	=> ( is => 'ro', isa => 'Num',   default=> 5); # Attempt to correct kmers that are seen less than this many times
has 'kmer_length'	    => ( is => 'ro', isa => 'Num',   default=> 31); # TODO: Calculate sensible default value
has 'output_filename'   => ( is => 'rw', isa => 'Str',   default  => '_sga_error_corrected.fastq' );
has 'sga_exec'          => ( is => 'rw', isa => 'Str',   required => 1 );
has 'debug'             => ( is => 'ro', isa => 'Bool',  default => 0);


sub run {
    my ($self) = @_;
    my $input_filename = $self->_gunzip_file_if_needed( $self->input_filename, $self->_temp_directory );
   
    my $original_cwd = getcwd();
    
    # Change to temporary directory for all intermediate steps
    chdir( $self->_temp_directory );
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);
	
	# Run the command to create the index 
    system(
        join(
            ' ',
            (
                $self->sga_exec, 'index',
                '-a', $self->algorithm,
                '-t', $self->threads, 
                '-d', $self->disk,
                '--no-reverse', 
               	$input_filename,
                $stdout_of_program
            )
        )
    );
    
    # Run the command to correct the read errors
     system(
        join(
            ' ',
            (
                $self->sga_exec, 'correct',
                '-k', $self->kmer_length,
                '--discard',
                '--learn',
                '-x', $self->kmer_threshold,
                '-t', $self->threads, 
                '-o', $self->output_filename,
               	$input_filename,
                $stdout_of_program
            )
        )
    );
    
    # change back to original cwd
    chdir($original_cwd);
    return $self;
}

sub _output_filename {
	my ($self) = @_;
	return join ('/', $self->_temp_directory, $self->output_filename);
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

