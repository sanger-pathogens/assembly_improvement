# Installation
To run the example data set through the improve_assembly script, you need to install the Perl dependancies and the required external dependancies. All the other dependancies are optional.

## Perl dependancies
The software and its Perl dependancies can be downloaded from CPAN. It requires Perl 5.14 or greater.

```cpanm -f Bio::AssemblyImprovement```

## Required external dependancies
### SSPACE and GapFiller
This is used by the improve_assembly, fill_gaps_with_gapfiller, and scaffold_with_sspace scripts.
Download SSPACE-standard and GapFiller from [Baseclear](http://www.baseclear.com/genomics/bioinformatics/basetools/SSPACE). The software is free for academic use.

## Optional external dependancies
### khmer
This is used for the diginorm_with_khmer script and can be downloaded and installed from the [khmer github repository](https://github.com/dib-lab/khmer). It requires python 2.7.

### MUMmer
This is used by ABACAS for reference based scaffolding as part of the improve_assembly and order_contigs_with_abacas scripts. It is widely available from package management systems such as HomeBrew/LinuxBrew and apt (Debian/Ubuntu) and the homepage is on [sourceforge](http://mummer.sourceforge.net/).

### SGA
This is used by the read_correction_with_sga script and can be downloaded from the [SGA github repository](https://github.com/jts/sga). It is widely available from package management systems such as HomeBrew/LinuxBrew and apt (Debian/Ubuntu).

### QUASR
This is used by the remove_primers_with_quasr script. It requires JAVA and can be downloaded from the [QUASR github repository](https://github.com/sanger-pathogens/QUASR).
