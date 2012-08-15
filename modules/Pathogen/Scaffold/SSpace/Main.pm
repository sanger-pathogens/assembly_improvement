
=head1 NAME

Main   - Create the config file thats used to drive SSpace

=head1 SYNOPSIS

use Pathogen::Scaffold::SSpace::Main;

my $config_file_obj = Pathogen::Scaffold::SSpace::Main->new(
  input_files => ['abc_1.fastq', 'abc_2.fastq'],
  input_assembly => 'contigs.fa'
  insert_size => 250,
  merge_size => 5,
  scaffolder_exec => '/path/to/SSPACE.pl'
)->run;

=cut

package Pathogen::Scaffold::SSpace::Main;
use Moose;
use File::Basename;
use Cwd;
use Pathogen::Scaffold::SSpace::Config;

has 'input_files'         => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'input_assembly'      => ( is => 'ro', isa => 'Str',      required => 1 );
has 'insert_size'         => ( is => 'ro', isa => 'Int',      required => 1 );
has 'merge_size'          => ( is => 'ro', isa => 'Int',      default  => 10 );
has 'scaffolder_exec'     => ( is => 'rw', isa => 'Str',      default  => 'SSPACE_Basic_v2.0.pl' );

has 'output_filename'     => ( is => 'rw', isa => 'Str', lazy     => 1, builder => '_build_output_filename' );
has '_temp_directory_obj' => ( is => 'ro', isa => 'Str', lazy     => 1, builder => '_build__temp_directory_obj' );
has '_temp_directory'     => ( is => 'ro', isa => 'Str', lazy     => 1, builder => '_build__temp_directory' );
has '_config_file_obj'    => ( is => 'ro', isa => 'Str', lazy     => 1, builder => '_build__config_file_obj' );

sub _build__config_file_obj
{
  my($self) = @_;
  Pathogen::Scaffold::SSpace::Config->new(
    input_files => $self->input_files,
    insert_size => $self->insert_size,
    output_filename => join('/',($self->_temp_directory,'_scaffolder_config_file'));
  )->create_config_file();
}

sub _build_output_filename
{
  my($self) = @_;
  my($filename, $directories, $suffix) = fileparse($self->input_assembly, qr/\.[^.]*/);
  $directories.$filename.".scaffolded".$suffix;
}

sub _build__temp_directory_obj
{
  my($self) = @_;
  File::Temp->newdir(CLEANUP => 1, DIR => getcwd());
}

sub _build__temp_directory
{
  my($self) = @_;
  $self->_temp_directory_obj->dirname();
}

sub run
{
  my($self) = @_;
  my $original_cwd = getcwd();
  chdir($self->_temp_directory);

  system(join(' ',('perl', $self->scaffolder_exec,'-l',$self->_config_file_obj->output_filename,'-n 31 -s',$self->input_assembly,'-x 1 -k',$self->merge_size, '-b scaffolded')));
  system("mv scaffolded.final.scaffolds.fasta ".$self->output_filename);
  chdir($original_cwd);
  return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;


