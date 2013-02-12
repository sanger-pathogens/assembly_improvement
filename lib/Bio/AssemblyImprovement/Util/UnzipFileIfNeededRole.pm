package Bio::AssemblyImprovement::Util::UnzipFileIfNeededRole;
# ABSTRACT: Role for unzipping files if needed

=head1 SYNOPSIS

Role for unzipping input files if they are zipped.

	with 'Bio::AssemblyImprovement::Util::UnzipFileIfNeededRole';

   	for my $filename ( @{ $self->input_files } ) {
    	
        push( @prepared_input_files, $self->_gunzip_file_if_needed( $filename,$self->_temp_directory));
    }    
=cut

use Moose::Role;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use Cwd;
use File::Basename;

sub _gunzip_file_if_needed {
  
    my ( $self, $input_filename, $output_directory ) = @_;
	return undef unless(defined($input_filename));
    $output_directory ||= abs_path (getcwd()); # If not given, default to current working directory
    
    if ( $input_filename =~ /\.gz$/ ) {
        my $base_filename = fileparse( $input_filename, qr/\.[^.]*/ );
        my $output_filename = join( '/', ( $output_directory, $base_filename ) );
        gunzip $input_filename => $output_filename or die "gunzip failed: $GunzipError\n";
        return $output_filename;
    }
    else {
        return $input_filename;
    }
}

no Moose;
1;
