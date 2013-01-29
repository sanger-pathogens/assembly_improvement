package Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads;

# ABSTRACT: Preprocess reads before error correction 

=head1 SYNOPSIS

Runs SGA step to preprocess reads. This object needs to be kept in scope 
because it creates temp files which are cleaned up when it goes out of scope.

   use Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads;

   my $process_input_files = Bio::AssemblyImprovement::Assemble::SGA::PreprocessReads->new(
     input_files => ['abc_1.fastq.gz', 'abc_2.fastq'],
   );

   $process_input_files->processed_file;
   
=method processed_read_file

Process the input FASTQ files using SGA and return a location to the resulting FASTQ file.

sga preprocess --pe-mode 1 -o 9119_preprocessed.fastq 9119_2#95_1.fastq 9119_2#95_2.fastq

=cut

use Moose;
use Cwd 'abs_path';
use Cwd;
use File::Basename;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

with 'Bio::AssemblyImprovement::Scaffold::SSpace::TempDirectoryRole';
with 'Bio::AssemblyImprovement::Util::UnzipFileIfNeededRole';

has 'input_files'     => ( is => 'ro', isa => 'ArrayRef' , required => 1);
has 'output_filename' => ( is => 'rw', isa => 'Str',      default  => '_sga_preprocessed.fastq' );
has 'sga_exec'        => ( is => 'rw', isa => 'Str',      required => 1 );
has 'debug'           => ( is => 'ro', isa => 'Bool', default => 0);


sub run {
    my ($self) = @_;
    my $prepared_input_files = $self->_prepare_input_files();
    my $original_cwd = getcwd();
    chdir( $self->_temp_directory );
    
    my $stdout_of_program = '';
    $stdout_of_program =  "> /dev/null 2>&1"  if($self->debug == 0);

    system(
        join(
            ' ',
            (
                'perl', $self->sga_exec, 'preprocess',
                '-pe-mode 1',
                '-o', $self->output_filename, 
               	$prepared_input_files->[0],
               	$prepared_input_files->[1],
                $stdout_of_program
            )
        )
    );
    chdir($original_cwd);
    return $self;
}

sub _prepare_input_files {
    my ($self) = @_;
    my @prepared_input_files;
    return undef unless(defined($self->input_files));
    
	# Unzip files if needed (into a temporary directory)
    for my $filename ( @{ $self->input_files } ) {
        push( @prepared_input_files, $self->_gunzip_file_if_needed( $filename,$self->_temp_directory));
    }
    
    return \@prepared_input_files;
}



no Moose;
__PACKAGE__->meta->make_immutable;
1;

