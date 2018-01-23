# Assembly Improvement

Take in an assembly in FASTA format, reads in FASTQ format, and make the assembly better by scaffolding and gap filling. 

[![Build Status](https://travis-ci.org/sanger-pathogens/assembly_improvement.svg?branch=master)](https://travis-ci.org/sanger-pathogens/assembly_improvement)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-brightgreen.svg)](https://github.com/sanger-pathogens/assembly_improvement/blob/master/software-license)
[![status](https://img.shields.io/badge/MGEN-10.1099%2Fmgen.0.000083-brightgreen.svg)](http://mgen.microbiologyresearch.org/content/journal/mgen/10.1099/mgen.0.000083)

## Contents
  * [Introduction](#introduction)
  * [Installation](#installation)
    * [Required external dependancies](#required-external-dependancies)
    * [Optional external dependancies](#optional-external-dependancies)
  * [Usage](#usage)
    * [improve\_assembly](#improve_assembly)
    * [descaffold\_assembly](#descaffold_assembly)
    * [diginorm\_with\_khmer](#diginorm_with_khmer)
    * [fastq\_tools](#fastq_tools)
    * [fill\_gaps\_with\_gapfiller](#fill_gaps_with_gapfiller)
    * [order\_contigs\_with\_abacas](#order_contigs_with_abacas)
    * [read\_correction\_with\_sga](#read_correction_with_sga)
    * [remove\_primers\_with\_quasr](#remove_primers_with_quasr)
    * [rename\_contigs](#rename_contigs)
    * [scaffold\_with\_sspace](#scaffold_with_sspace)
  * [License](#license)
  * [Feedback/Issues](#feedbackissues)
  * [Citation](#citation)

## Introduction
This software takes an assembly in FASTA format along with reads in FATSQ format and improves the assembly by scaffolding and gap filling. The software contains several separate scripts, including improve_assembly, descaffold_assembly, diginorm_with_khmer, fastq_tools, order_contigs_with_abacas, read_correction_with_sga, remove_primers_with_quasr, rename_contigs and scaffold_with_sspace. For more information on what each scrips does, please see the usage below.

## Installation

### Required external dependancies
 * SSPACE and GapFiller - This is used by the improve_assembly, fill_gaps_with_gapfiller, and scaffold_with_sspace scripts. Download SSPACE-standard and GapFiller from [Baseclear](http://www.baseclear.com/genomics/bioinformatics/basetools/SSPACE). The software is free for academic use.

### Optional external dependancies
 * khmer - This is used for the diginorm_with_khmer script and can be downloaded and installed from the [khmer github repository](https://github.com/dib-lab/khmer). It requires python 2.7.
 * MUMmer - This is used by ABACAS for reference based scaffolding as part of the improve_assembly and order_contigs_with_abacas scripts. It is widely available from package management systems such as HomeBrew/LinuxBrew and apt (Debian/Ubuntu) and the homepage is on [sourceforge](http://mummer.sourceforge.net/).
 * SGA - This is used by the read_correction_with_sga script and can be downloaded from the [SGA github repository](https://github.com/jts/sga). It is widely available from package management systems such as HomeBrew/LinuxBrew and apt (Debian/Ubuntu).
 * QUASR - This is used by the remove_primers_with_quasr script. It requires JAVA and can be downloaded from the [QUASR github repository](https://github.com/sanger-pathogens/QUASR).

The software and its Perl dependancies can be downloaded from CPAN. It requires Perl 5.14 or greater.

```cpanm -f Bio::AssemblyImprovement```

If you encounter an issue when installing assembly_improvement please contact your local system administrator. If you encounter a bug please log it [here](https://github.com/sanger-pathogens/assembly_improvement/issues) or email us at path-help@sanger.ac.uk

## Usage

### improve_assembly
The improve_assembly script is the main script for the repository. The usage is:

```
Usage: improve_assembly [options] -a <FASTA> -f <FASTQ> -r <FASTQ> -s <EXEC> -g <EXEC>
Given an assembly in FASTA format and paired ended reads in FASTQ format, output a scaffolded and gapfilled assembly.

Required: 	
    -a STR  assembly FASTA(.gz) file
    -f STR  forward reads FASTQ(.gz) file
    -r STR  reverse reads FASTQ(.gz) file
    -s STR  path to SSPACE executable
    -g STR  path to GapFiller executable
Options:    
    -c STR  reference FASTA(.gz) file
    -i INT  insert size [250]
    -b STR  path to abacas.pl executable
    -o STR  output directory [.]
    -l INT  Minimum final contig length [300]
    -p INT  Only filter if this percentage of bases left [95]
    -d      debug output []
    -h      print this message and exit
```

To scaffold and gap fill an assembly you run:

```improve_assembly -a contigs.fa -f 123_1.fastq -r 123_2.fastq```

This will output files for each stage in the script, with the various processes performed in the filename. The final filename in this case is scaffolds.scaffolded.gapfilled.length_filtered.sorted.fa.

A reference genome can be used to additionally orientate and order the contigs using ABACAS. This is useful for when you have a close by high quality reference sequence. 

```improve_assembly -a contigs.fa -f 123_1.fastq -r 123_2.fastq  -c my_reference.fa```

The input files can be optionally gzipped.

```improve_assembly -a contigs.fa.gz -f 123_1.fastq.gz -r 123_2.fastq.gz```

The insert size (fragment size) should ideally be set to the actual insert size. Be aware that the insert size you ask for can often differ from the actual insert size achieved in the lab.  It is assumed that most of the reads will fall within 30% of the insert size given.  To change it use -i:

```improve_assembly -a contigs.fa -f 123_1.fastq -r 123_2.fastq -i 500```

Small contigs are filtered out at the end (default 300 bases).

```improve_assembly -a contigs.fa -f 123_1.fastq -r 123_2.fastq -l 500```

The filtering step is only run if the size of the assembly is at least 95% of the input size. This can be changed using -p:

```improve_assembly -a contigs.fa -f 123_1.fastq -r 123_2.fastq -p 95```

The output directory for the results can be set using -o.

```improve_assembly -a contigs.fa -f 123_1.fastq -r 123_2.fastq -o my_directory```


### descaffold_assembly
Given a FASTA file, break up each sequence where there is a gap.

```Usage: descaffold_assembly -a <FASTA>```

### diginorm_with_khmer
A wrapper script around the khmer normalize-by-median.py script. This is useful where you have uneven coverage. For example in certain virus sequencing experiments, there can be 10,000X coverage however different parts of the genome may have been amplified so the actual coverage can have massive peaks and troughs.  

```
Usage: diginorm_with_khmer [options] -i <FASTQ>

Required:
    -i  STR   input FASTQ(.gz) file of shuffled reads
Options:
    -c  INT   target median coverage [2]
    -k  INT   length of kmer to be used, higher numbers require more RAM [31]
    -n  INT   number of hashes [4]
    -m  FLOAT minimum hash size. [2.5e8]
    -o  STR   output directory [.]
    -z  STR   output filename [digitally_normalised.fastq.gz]
    -e  STR   path to normalize-by-median.py
    -py STR   python executable [python-2.7]
    -d        debug output []
    -h        print this message and exit
```

### fastq_tools
This script has some useful utilities for analysing a shuffled paired ended FASTQ file. We know they are available in other applications but to minimise dependancies we reimplemented them and have exposed them here for completeness sake.

```
Usage: fastq_tools [options] -i <FASTQ>
	
Required:	
    -i STR  input FASTQ(.gz) file of shuffled reads
    -t STR  task to be run (kmer/coverage/split/histogram)
Options:
    -g INT  genome size of the coverage task []
    -h      print this message and exit
````

Calculate 66% and 90% of median read length as minimum and maximum kmer sizes for use when runnning VelvetOptimiser:

```fastq_tools -i input.fastq -t kmer```

To calculate the coverage of a genome:

```fastq_tools -i input.fastq -t coverage -g 5000000```

To split a shuffled paired ended FASTQ file into 2 FASTQ files, one containing the forward reads and another containing the reverse reads. At the end of each read name /1 (forward) or /2 (reverse) is appended:

```fastq_tools -i input.fastq -t split```

To produce a histogram (histogram.png) of the read lengths found in the FASTQ file. This is useful for after you have trimmed the reads to get an indication of whats left:

```fastq_tools -i input.fastq -t histogram```

### fill_gaps_with_gapfiller
Given an assembly in FASTA format and paired ended reads in FASTQ format, iteratively fill in gaps with GapFiller. Initially a high level of read coverage is required to close a gap, which decreases with subsequent iterations. The means that bases with the highest level of evidence are filled in first, reducing the possiblity of errors.

```
Usage: fill_gaps_with_gapfiller [options] -a <FASTA> -f <FASTQ> -r <FASTQ> -g <EXEC>
Take in an assembly in FASTA format and reads in FASTQ format, then iteratively fill in the gaps with GapFiller.
Required: 	
    -a STR  assembly FASTA(.gz) file
    -f STR  forward reads FASTQ(.gz) file
    -r STR  reverse reads FASTQ(.gz) file
    -g STR  path to GapFiller executable
Options:    
    -i INT  insert size [250]
    -t INT  number of threads [1]
    -o STR  output directory [.]
    -d      debug output []
    -h      print this message and exit

```

### order_contigs_with_abacas
A wrapper script around ABACAS for ordering contigs against a reference.

```
Usage: order_contigs_with_abacas -a <FASTA> -c <FASTA>
Take in an assembly and a reference in FASTA format and order the contigs.

Required: 
    -a STR  assembly FASTA(.gz) file
    -c STR  reference genome FASTA(.gz) file
Options: 
    -b STR  ABACAS executable [abacas.pl]
    -h      print this message and exit
```

### read_correction_with_sga
A wrapper script around SGA read correction which sets some common defaults.

```
Usage: read_correction_with_sga [options] -f <FASTQ> -r <FASTQ> -s <EXEC>
Takes in FASTQ files and produces read corrected fastq files using SGA.

Required:
    -f STR  forward reads FASTQ(.gz) file
    -r STR  reverse reads FASTQ(.gz) file
    -s STR  path to SGA executable
Options:    
    -m INT  minimum read length [66]
    -q      trim reads using BWT trimming algorithm
    -a STR  indexing algorithm to use (ropebwt/sais) [ropebwt]
    -t INT  number of threads [1]
    -o STR  output directory [.]
    -h INT  kmer threshold [5]
    -k INT  length of kmer to be used [41]
    -z STR  output filename [_sga_error_corrected.fastq.gz]
    -d      debug output []
```

### remove_primers_with_quasr
A wrapper script around QUASR.

### rename_contigs
Rename all sequences in a FASTA file with a common base name and a sequential number.

```
Usage: rename_contigs [options]
Given an assembly, rename the contigs iteratively
Required:
    -a STR  assembly FASTA(.gz) file
    -b STR  basename for sequences
Options:    
    -h      print this message and exit
```

### scaffold_with_sspace
A script to iteratively run scaffold an assembly using paired ended reads using SSPACE. Multiple iterations of scaffolding are run, begining where there is the highest level of read pair evidence linking together 2 contigs. It then outputs the scaffolded assembly in FASTA format.

```
Usage: scaffold_with_sspace [options] -a <FASTA> -f <FASTQ> -r <FASTQ> -s <EXEC>
Take in an assembly in FASTA format and reads in FASTQ format, then iteratively scaffold with SSPACE.
Required: 	
    -a STR  assembly FASTA(.gz) file
    -f STR  forward reads FASTQ(.gz) file
    -r STR  reverse reads FASTQ(.gz) file
    -s STR  path to SSPACE executable
Options:    
    -i INT  insert size [250]
    -t INT  number of threads [1]
    -o STR  output directory [.]
    -d      debug output []
    -h      print this message and exit
```
## License
assembly_improvement is free software, licensed under [GPLv3](https://github.com/sanger-pathogens/assembly_improvement/blob/master/software-license).

## Feedback/Issues
Please report any issues to the [issues page](https://github.com/sanger-pathogens/assembly_improvement/issues) or email path-help@sanger.ac.uk

## Citation
If you use this software please cite:

   "Robust high throughput prokaryote de novo assembly and improvement pipeline for Illumina data",
   Page AJ, De Silva, N., Hunt M, Quail MA, Parkhill J, Harris SR, Otto TD, Keane JA,
   Microbial Genomics, 2016. doi: [10.1099/mgen.0.000083](http://mgen.microbiologyresearch.org/content/journal/mgen/10.1099/mgen.0.000083)