#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use Cwd;
use Cwd qw(abs_path);

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::Scaffold::SSpace::PreprocessInputFiles');
}

my $current_dir = abs_path( getcwd() );

ok(
    (
        my $process_input_files = Bio::AssemblyImprovement::Scaffold::SSpace::PreprocessInputFiles->new(
            input_files    => [ 't/data/forward.fastq', 't/data/reverse.fastq' ],
            input_assembly => 't/data/small_contigs.fa',
            minimum_contig_size_in_assembly => 1
        )
    ),
    'all unzipped'
);
is(
    $process_input_files->processed_input_assembly,
    $process_input_files->_temp_directory . '/small_contigs.fa.filtered',
    'unzipped contigs file the same location'
);
is_deeply(
    $process_input_files->processed_input_files,
    [ $current_dir . '/t/data/forward.fastq', $current_dir . '/t/data/reverse.fastq' ],
    'unzipped contigs file the same location'
);


ok(
    (
        $process_input_files = Bio::AssemblyImprovement::Scaffold::SSpace::PreprocessInputFiles->new(
            input_files    => [ 't/data/forward.fastq.gz', 't/data/reverse.fastq' ],
            input_assembly => 't/data/small_contigs.fa.gz',
            minimum_contig_size_in_assembly => 1
        )
    ),
    'some zipped'
);
isnt(
    $process_input_files->processed_input_assembly,
    $current_dir . '/t/data/small_contigs.fa',
    'unzipped contigs file is in a different location'
);
isnt(
    $process_input_files->processed_input_files->[0],
    $current_dir . '/t/data/forward.fastq',
    'unzipped fastq is in a different location'
);
is(
    $process_input_files->processed_input_files->[1],
    $current_dir . '/t/data/reverse.fastq',
    'reverse fastq wasnt changed because it was unzipped to begin with'
);
my $forward_filename_post_unzip = fileparse($process_input_files->processed_input_files->[0] );
is($forward_filename_post_unzip, 'forward.fastq', 'correct unzipped filename');



ok(
    (
        $process_input_files = Bio::AssemblyImprovement::Scaffold::SSpace::PreprocessInputFiles->new(
            input_files    => [ 't/data/forward.fastq.gz', 't/data/reverse.fastq.gz' ],
            input_assembly => 't/data/small_contigs.fa.gz',
            minimum_contig_size_in_assembly => 1
        )
    ),
    'all zipped'
);
isnt(
    $process_input_files->processed_input_assembly,
    $current_dir . '/t/data/small_contigs.fa',
    'unzipped contigs file is in a different location'
);
isnt(
    $process_input_files->processed_input_files->[0],
    $current_dir . '/t/data/forward.fastq',
    'unzipped fastq is in a different location'
);
isnt(
    $process_input_files->processed_input_files->[1],
    $current_dir . '/t/data/reverse.fastq',
    'unzipped fastq is in a different location'
);
$forward_filename_post_unzip = fileparse($process_input_files->processed_input_files->[0] );
is($forward_filename_post_unzip, 'forward.fastq', 'correct unzipped filename');

my $reverse_filename_post_unzip = fileparse($process_input_files->processed_input_files->[1] );
is($reverse_filename_post_unzip, 'reverse.fastq', 'correct unzipped filename');

done_testing();
