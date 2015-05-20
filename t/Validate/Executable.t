#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;
use File::Spec;
use File::Which;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Validate::Executable');
}

my $current_dir = getcwd();
# 
# my  @PATH = File::Spec->path();
# print "My full path: \n";
# print "@PATH\n";
# 
# my @exec_path = which('t/dummy_sspace_script.pl');
# print "Exec path \n";
# print "@exec_path\n";

#Dummy default executables
my $sspace_default = $current_dir.'/t/dummy_sspace_script.pl';
my $gapfiller_default  = $current_dir.'/t/dummy_gap_filler_script.pl';
my $abacas_default     = $current_dir.'/t/dummy_abacas_script.pl';

#Test values
my $my_sspace = $current_dir.'/t/dummy_sspace_v2_script.pl'; # different version to default
my $my_gapfiller = $current_dir.'/t/does_not_exist.pl'; # script does not exist
my $my_abacas; # not defined

$my_sspace = Bio::AssemblyImprovement::Validate::Executable->new()->check_executable_and_set_default($my_sspace, $sspace_default);
$my_gapfiller = Bio::AssemblyImprovement::Validate::Executable->new()->check_executable_and_set_default($my_gapfiller, $gapfiller_default);
$my_abacas = Bio::AssemblyImprovement::Validate::Executable->new()->check_executable_and_set_default($my_abacas, $abacas_default);

is($my_sspace, $current_dir.'/t/dummy_sspace_v2_script.pl');
is($my_gapfiller, $gapfiller_default);
is($my_abacas, $abacas_default);

done_testing();