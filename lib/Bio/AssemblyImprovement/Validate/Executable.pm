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
  # if its a full path then skip over it
  return 1 if($exec =~ m!/!);

  my @full_paths_to_exec = which($exec);
  return 0 if(@full_paths_to_exec == 0);
  
  return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
