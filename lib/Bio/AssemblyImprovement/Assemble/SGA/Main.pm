package Bio::AssemblyImprovement::SGA::Main;
# ABSTRACT: Run SGA (preprocess and error correction)

=head1 SYNOPSIS


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

has 'input_files'     => ( is => 'ro', isa => 'ArrayRef' , required => 1);
has 'sga_exec'        => ( is => 'rw', isa => 'Str',      required => 1 );
has 'algorithm'	      => ( is => 'ro', isa => 'Str', default => 'ropebwt'); # BWT construction algorithm: sais or ropebwt
has 'threads'	      => ( is => 'ro', isa => 'Num', default => 1); # Use this many threads to construct the index
has 'kmer_length'	  => ( is => 'ro', isa => 'Num', default=> 31); # Sensible default value? 41?

# Should we allow users to specify output filenames? Or just use defaults?

sub run {
    my ($self) = @_;
    my $original_cwd = getcwd();
    chdir( $self->_temp_directory );
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);
    
    my $sga_preprocessor    = Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads->new(
            input_files     => [ $self->input_files[0], $self->input_files[1] ] ,
            sga_exec        => $self->$sga_exec,
    );

	$sga_preprocessor->run();
	my $preprocessed_file  = $sga_preprocessor->_output_filename();
	
	my $sga_error_corrector = Bio::AssemblyImprovement::Assemble::SGA::IndexAndCorrectReads->new(
      input_filename 		=> $preprocessed_file,
      algorithm      		=> $self->algorithm,
      threads        		=> $self->threads,
      kmer_length	 		=> $self->kmer_length,
      sga_exec	     		=> $self->sga_exec,
    );

	$sga_error_corrector->run();
	my $corrected_file = $sga_error_corrector->_output_filename();
   
    # move( $self->_intermediate_file_name, $self->output_filename ); # Move results file to sensible location....where?
    chdir($original_cwd);
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

