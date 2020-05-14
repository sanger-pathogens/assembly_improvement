#!/usr/bin/env perl
use strict;
use warnings;

BEGIN {
    use Test::Most;
    use_ok('Bio::AssemblyImprovement::AdapterRemoval::Trimmomatic::Main');
}


ok(my $obj = Bio::AssemblyImprovement::AdapterRemoval::Trimmomatic::Main->new(
    'reads_in_1'       => 't/data/trimmo_reads_1.fastq',
    'reads_in_2'       => 't/data/trimmo_reads_2.fastq',
    'paired_out_1'     => 'trimmed.paired_1.fastq',
    'paired_out_2'     => 'trimmed.paired_2.fastq',
    'unpaired_out_1'   => 'trimmed.unpaired_1.fastq',
    'unpaired_out_2'   => 'trimmed.unpaired_2.fastq',
    'trimmomatic_exec' => 't/DummyTrimmomatic.jar',
    'adapters_file'    => 't/data/trimmo_adapters.fasta',
), 'initialize object');

$obj->run();

ok(-e 'trimmed.paired_1.fastq', 'Paired reads 1 file OK');
ok(-e 'trimmed.paired_2.fastq', 'Paired reads 2 file OK');
ok(-e 'trimmed.unpaired_1.fastq', 'Unpaired reads 1 file OK');
ok(-e 'trimmed.unpaired_2.fastq', 'Unpaired reads 2 file OK');

done_testing();
