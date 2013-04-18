package Bio::AssemblyImprovement::DigitalNormalisation::Khmer::Main;

# ABSTRACT: Perform digital normalisation on sequencing reads

=head1 SYNOPSIS

Runs digital normalisation using khmer. Final results file (zipped) produced in directory of your choice 
(default: current working directory)

my $digi_norm = Bio::AssemblyImprovement::DigitalNormalisation::Khmer::Main->new(
        input_file     	 => 'abc_shuffled.fastq',
        desired_coverage => '40',
        khmer_exec       => '/path/to/normalise/script.py',
        python_exec      => 'python-2.7',
)->run; 
my $results = $digi_norm->_final_results_file;
     
=method 

=method run

=method _final_results_file

Return full path to the results file


=cut

use Moose;
use Cwd 'abs_path';
use Cwd;
use File::Basename;
use File::Copy;

use Bio::AssemblyImprovement::Util::FastqTools;

with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';
with 'Bio::AssemblyImprovement::Util::ZipFileRole';

has 'input_file'        => ( is => 'ro', isa => 'Str' , required => 1);
has 'desired_coverage'  => ( is => 'ro', isa => 'Num', default  => 2 );
has 'kmer_size'	        => ( is => 'ro', isa => 'Num', default => 31); 
has 'number_of_hashes'	=> ( is => 'ro', isa => 'Num', default => 4); 
has 'min_hash_size'	    => ( is => 'ro', isa => 'Str', default => '2.5e8'); 
has 'paired'	        => ( is => 'ro', isa => 'Bool', default => 1); # The pipeline will almost always be sending paired data
has 'output_filename'   => ( is => 'rw', isa => 'Str',  default  => 'digitally_normalised.fastq.gz' );
has 'output_directory'  => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build_output_directory' ); # Default to cwd
has 'khmer_exec'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'python_exec'	    => ( is => 'ro', isa => 'Str', default => 'python-2.7');
has 'debug'             => ( is => 'ro', isa => 'Bool', default  => 0);


sub _build_output_directory{
  my ($self) = @_;
  return getcwd();
}

sub _final_results_file {
	my ($self) = @_;
	return $self->output_directory.'/'.$self->output_filename;
}

sub _default_output_filename {
	my ($self) = @_;
	my ( $filename, $directories, $suffix ) = fileparse( $self->input_file );
	# The output produced by the program is a fastq file (unzipped) named $input_filename.keep	
	return join ('/', getcwd(), $filename.'.keep');
}



sub run {
    my ($self) = @_;
    my $original_cwd = getcwd();
    
    # Usually, we'd do all the intermediate steps in a temporary directory and copy over the results file.
    # This doesn't produce any intermediate files so we carry on working in the directory we are in
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);
    
    my $paired_parameter = "";
    if($self->paired){
    	$paired_parameter = "-p";
    }
    
    system(
        join(
            ' ',
            (
                $self->python_exec, $self->khmer_exec, #Need atleast python-2.7 for this
                $paired_parameter, # Paired
                '-C', $self->desired_coverage,
                '-k', $self->kmer_size,
                '-N', $self->number_of_hashes,
                '-x', $self->min_hash_size, 
               	$self->input_file,
                $stdout_of_program
            )
        )
    );
    
    # By default, the script produces a fastq file named with the input filename and a .keep suffix
    # We want to have the flexibility of calling it something we like. Hence, the move below. 
    
    my $zipped_results = $self->_zip_file( $self->_default_output_filename , $self->output_directory ); #As a principle, we always zip our results
	move ( $zipped_results, $self->_final_results_file);
	            
    return $self;
}




no Moose;
__PACKAGE__->meta->make_immutable;
1;

