package Bio::AssemblyImprovement::PrimerRemoval::Main;

# ABSTRACT: Remove a set of specified primers from the edges of a read using QUASR

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

has 'forward_file'           => ( is => 'ro', isa => 'Str' , required => 1); 
has 'reverse_file'           => ( is => 'ro', isa => 'Str' , required => 1);
has 'output_directory'       => ( is => 'ro', isa => 'Str' , builder => '_build_output_directory'); # Will default to current working directory
has 'output_f_filename'		 => ( is => 'ro', isa => 'Str' , removed => 'primer_removed.forward.fastq.gz');
has 'output_r_filename'		 => ( is => 'ro', isa => 'Str' , removed => 'primer_removed.reverse.fastq.gz');
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

sub _final_results_files {
	my ($self) = @_;
	my @results_files;
	push(@results_files, $self->output_directory.'/'.$self->output_f_filename);
	push(@results_files, $self->output_directory.'/'.$self->output_r_filename);
	return @results_files;
}

sub _default_results_files {
	my ($self) = @_;
	# QUASR will produce a forward and reverse file called $output_prefix with a 'f/r.qc.fastq' suffix. We specify the -z flag so it will also be zipped
	my @default_results_files;
	push(@default_results_files, $self->output_directory.'/primer_removed.f.qc.fq.gz');
	push(@default_results_files, $self->output_directory.'/primer_removed.r.qc.fq.gz');	
	return @default_results_file;
}

sub run {
    my ($self) = @_;
    
    chdir( $self->output_directory ); # Change to desired output directory
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);

    system(
        join(
            ' ',
            (
                'java -jar', $self->QUASR_exec, 
                '-i', $self->forward_file,
                '-r', $self->reverse_file,
                '-o', 'primer_removed',
                '-p', $self->primers_file,
                '-L', $self->leeway, 
                '-l', $self->minimum_length,
                '-m', $self->median_quality_cutoff,
                '-z', #Zip the output file
                $stdout_of_program
            )
        )
    );
    
	# Make sure we end up with files with names that we want
	my @default_files = $self->_default_results_files;
	my @desired_files = $self->_final_results_files;	
	move($default_files[0], $desired_files[0]);
	move($default_files[1], $desired_files[1]);
	
    
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

