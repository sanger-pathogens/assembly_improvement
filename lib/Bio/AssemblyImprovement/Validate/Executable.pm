package Bio::AssemblyImprovement::Validate::Executable;

# ABSTRACT: Validates the executable is available in the path before running it.

=head1 SYNOPSIS

Validates the executable is available in the path before running it.

   use Bio::AssemblyImprovement::Validate::Executable;
   Bio::AssemblyImprovement::Validate::Executable
      ->new()
      ->does_executable_exist('abc');

=method does_executable_exist

Check to see if an executable is available in the current users PATH.

=cut

use Moose;
use File::Which;

sub does_executable_exist
{
  my($self, $exec) = @_;
	if(-x $exec){
		return 1;
	}
	return 0;

}

sub check_executable_and_set_default
{
	my($self, $exec, $default) = @_;
	
	if(!defined $exec){
		return $default;
	}else{
		if($self->does_executable_exist($exec)){
			return $exec;
		}else{
			warn "$exec does not exist. Using default: $default";
			return $default;
		}
	}
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
