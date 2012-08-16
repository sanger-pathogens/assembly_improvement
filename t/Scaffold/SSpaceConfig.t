#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp;

BEGIN { unshift( @INC, './modules' ) }

BEGIN {
    use Test::Most;
    use_ok('Pathogen::Scaffold::SSpace::Config');
}

# 2 input files
my $tmpdirectory_obj = File::Temp->newdir( CLEANUP => 1 );
my $config_file_output = $tmpdirectory_obj->dirname() . "/_config_file";
ok(
    my $config_file_obj = Pathogen::Scaffold::SSpace::Config->new(
        input_files     => [ 'abc_1.fastq', 'abc_2.fastq' ],
        insert_size     => 250,
        output_filename => $config_file_output
    ),
    'initialise config file creation'
);
ok( $config_file_obj->create_config_file(), 'Create the config file' );
ok( ( -e $config_file_output ), 'config file exists' );
open( IN, $config_file_output ) or die "Couldnt open config file";
is( <IN>, 'LIB abc_1.fastq abc_2.fastq 250 0.3 FR', 'expected content returned' );

# one input file
$tmpdirectory_obj = File::Temp->newdir( CLEANUP => 1 );
$config_file_output = $tmpdirectory_obj->dirname() . "/_config_file";
ok(
    $config_file_obj = Pathogen::Scaffold::SSpace::Config->new(
        input_files     => ['abc_1.fastq'],
        insert_size     => 250,
        output_filename => $config_file_output
    ),
    'initialise config file creation for single file'
);
ok( $config_file_obj->create_config_file(), 'Create the config file for single file' );
ok( ( -e $config_file_output ), 'config file exists for single file' );
open( IN, $config_file_output ) or die "Couldnt open config file for single file";
is( <IN>, 'LIB abc_1.fastq 250 0.3 FR', 'expected content returned for single file' );

done_testing();
