package Bio::AssemblyImprovement::Subsampling::Khmer::Main;

# ABSTRACT: Perform digital normalisation on sequencing reads

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

use Bio::AssemblyImprovement::Util::FastqTools;

with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';

has 'input_file'        => ( is => 'ro', isa => 'ArrayRef' , required => 1);
has 'desired_coverage'  => ( is => 'ro', isa => 'Num', default  => 200 );
has 'kmer_size'	        => ( is => 'ro', isa => 'Num', default => 40); 
has 'number_of_hashes'	=> ( is => 'ro', isa => 'Num', default => 4); 
has 'min_hash_size'	    => ( is => 'ro', isa => 'Str', default => '2.5e8'); 
has 'paired'	        => ( is => 'ro', isa => 'Bool', default => 1); # The pipeline will almost always be sending paired data
has 'savehash'	        => ( is => 'ro', isa => 'Str', default => 'khmer_normalise.kh'); # We will need this hash if we decide to implement subsequent steps in this program
has 'report_file'	    => ( is => 'ro', isa => 'Str', default => 'khmer_normalise.report'); # Optional report file that logs that actions of the normalisation
has 'debug'             => ( is => 'ro', isa => 'Bool', default  => 0);


sub run {
    my ($self) = @_;
    my $original_cwd = getcwd();
    
    # Usually, we'd do all the intermediate steps in a temporary directory and copy over the results file.
    # This doesn't produce any intermediate files - just the results and a report (which, if produced, we are keeping)
    
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
                'python-2.7', $self->khmer_exec, #Need atleast python-2.7 for this
                $paired_parameter, # Paired
                '-C', $self->desired_coverage,
                '-k', $self->kmer_size,
                '-N', $self->number_of_hashes,
                '-x', $self->min_hash_size, 
                '--report-to-file', $self->report_file,
                '--savehash', $self->savehash,
               	$self->input_file,
                $stdout_of_program
            )
        )
    );
    
    return $self;
}

sub _output_filename {
	my ($self) = @_;
	my ( $filename, $directories, $suffix ) = fileparse( $self->input_file );
	# The output produced by the program is a fastq file (unzipped) named input_filename.keep	
	return join ('/', getcwd(), $filename.'.keep');
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

