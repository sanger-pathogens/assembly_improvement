package Bio::AssemblyImprovement::PrimerRemoval::Main;

# ABSTRACT: Remove a set of specified primers from the edges of a read

=head1 SYNOPSIS

   
=method 

=method run



=method _output_filename

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

has 'input_file'             => ( is => 'ro', isa => 'Str' , required => 1); #QUASR can also take in a forward and reverse file, but for our purposes we just assume that the input is a shuffled paired file. Can take gzipped file
has 'output_prefix'          => ( is => 'ro', isa => 'Str' , default => 'primer_removed'); #Output file prefix
has 'output_directory'       => ( is => 'ro', isa => 'Str' , builder => '_build_output_directory'); # Will default to current working directory
has 'primers_file'  	     => ( is => 'ro', isa => 'Str', required => 1);
has 'leeway'	      	     => ( is => 'ro', isa => 'Num', default => 5); #Maximum distance primer can be within a read [ QUASR default: 40]
has 'minimum_length'	     => ( is => 'ro', isa => 'Num', default => '50'); #Minimum read length cut off
has 'median_quality_cutoff'	 => ( is => 'ro', isa => 'Num', default => 30); #Median read quality cutoff [QUASR default: 20.0]
has 'QUASR_exec'             => ( is => 'ro', isa => 'Str', required => 1 );
has 'debug'                  => ( is => 'ro', isa => 'Bool', default  => 0);


sub _build_output_directory{
  my ($self) = @_;
  return getcwd();
}

sub _final_results_file {
	my ($self) = @_;
	return $self->output_directory.'/'.$self->output_prefix.'.qc.fastq.gz';
}

sub _default_results_file {
	my ($self) = @_;
	# QUASR will produce a file called $output_prefix with a 'qc.fastq' suffix. We specify the -z flag so it will also be zipped
	return getcwd().'/'.$self->output_prefix.'.qc.fastq.gz';
}

sub run {
    my ($self) = @_;
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);

    system(
        join(
            ' ',
            (
                'java -jar', $self->QUASR_exec, 
                '-i', $self->input_file,
                '-o', $self->output_prefix,
                '-p', $self->primers_file,
                '-L', $self->leeway, 
                '-l', $self->minimum_length,
                '-m', $self->median_quality_cutoff,
                '-z', #Zip the output file
                $stdout_of_program
            )
        )
    );
    
    #For times when the required output directory is not the current working directory, the following move is necessary
    if(getcwd() ne $self->output_directory){
    	move( $self->_default_results_file, $self->_final_results_file);
    }
    
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

