package Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads;

# ABSTRACT: Preprocess reads before error correction 

=head1 SYNOPSIS

Runs SGA step to preprocess reads. The preprocessed reads will be in a file called _sga_preprocessed.fastq
in a temporary directory (unless an alternative file name is provided). When this object
goes out of scope this temporary directory will be cleaned up. Any module/script wishing to use these results
should move them to desired location.


   use Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads;

   my $sga_preprocessor = Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads->new(
            input_files     => [ 'forward.fastq', 'reverse.fastq.gz' ] ,
            output_filename => 'mypreprocessedreads.fastq',
            sga_exec        => 'path/to/sga_script.pl',
   );
   
   $sga_preprocessor->run();
   my $preprocessed_file = $sga_preprocessor->_output_filename();
   
=method _prepare_input_files

Unzip input files if needed

=method run

Run sga preprocess on the input data. 

=method _output_filename

Return full path to the results file


=cut

use Moose;
use Cwd 'abs_path';
use Cwd;
use File::Basename;

with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';
with 'Bio::AssemblyImprovement::Util::UnzipFileIfNeededRole';

has 'input_files'      => ( is => 'ro', isa => 'ArrayRef' , required => 1);
has 'output_filename'  => ( is => 'rw', isa => 'Str', default  => '_sga_preprocessed.fastq' );
has 'min_length'	   => ( is => 'ro', isa => 'Num', default => 66); # Change this to be the value of the minimum kmer length used by the assembler later on in the pipeline
has 'pe_mode'		   => ( is => 'ro', isa => 'Num', default => 2); #We set default to 2 as the pipeline will almost always send in an interleaved fastq file
has 'quality_trim'	   => ( is => 'ro', isa => 'Num', default => 20); # Use a quality score of 20 by default
has 'sga_exec'         => ( is => 'rw', isa => 'Str', required => 1 );
has 'debug'            => ( is => 'ro', isa => 'Bool', default  => 0);


sub run {
    my ($self) = @_;
    my $prepared_input_files = $self->_prepare_input_files();
    my $original_cwd = getcwd();
   
    # Do all the steps in a temporary directory
    chdir( $self->_temp_directory );
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);
    
    my $files_string = join (' ', @$prepared_input_files ); #Could be one shuffled file, or two files with forward and reverse reads 

    system(
        join(
            ' ',
            (
                $self->sga_exec, 'preprocess',
                '--pe-mode', $self->pe_mode, 
                #'--permute-ambiguous', # Do not randomly change ambiguous base calls - we would rather reads with ambiguous bases be thrown away
                '--min-length', $self->min_length,
                #'--quality-filter', $self->quality_filter, # Not doing any filtering since 1.3.2013
                '--quality-trim', $self->quality_trim,
                '--out', $self->output_filename, 
               	$files_string,
                $stdout_of_program
            )
        )
    );
    
    # Return to original cwd
    chdir($original_cwd);
    return $self;
}

sub _output_filename {
	my ($self) = @_;
	return join ('/', $self->_temp_directory, $self->output_filename);
}

sub _prepare_input_files {
    my ($self) = @_;
    my @prepared_input_files;
    
	# Unzip files if needed (into a temporary directory)
    for my $filename ( @{ $self->input_files } ) {
    	
        push( @prepared_input_files, $self->_gunzip_file_if_needed( $filename,$self->_temp_directory));
    }    
    return \@prepared_input_files;
}



no Moose;
__PACKAGE__->meta->make_immutable;
1;

