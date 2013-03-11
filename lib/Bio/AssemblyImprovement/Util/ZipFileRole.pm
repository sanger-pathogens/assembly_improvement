package Bio::AssemblyImprovement::Util::ZipFileRole;
# ABSTRACT: Zip file

=head1 SYNOPSIS

Role for zipping files (not tested yet)

	with 'Bio::AssemblyImprovement::Util::ZipFileRole';
   
=cut

use Moose::Role;
use IO::Compress::Gzip qw(gzip $GzipError) ;
use Cwd qw(abs_path);
use Cwd;
use File::Basename;

sub _zip_file {
  
    my ( $self, $input_filename, $output_directory ) = @_;
    
	return undef unless(defined($input_filename));
	
    $output_directory ||= abs_path (getcwd()); 
    
    #my $filename = fileparse( $input_filename );
    my ( $filename, $directories, $suffix ) = fileparse( $input_filename );
    my $filename = join( '/', ( $output_directory, $filename.'.'.$suffix.'.gz' ) );
    my $output_filename = join( '/', ( $output_directory, $filename.'.gz' ) );
    gzip $input_filename => $output_filename or die "gzip failed: $GzipError\n";
    return $output_filename;

}

no Moose;
1;
