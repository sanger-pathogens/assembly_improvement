# Example

This directory contains a real test data set of Illumina sequencing reads of a plasmid from Salmonella Weltevreden. The strain name is VNS10259 and sample accession is ERS208985. It was simultationously sequenced on Illumina (accesion ERR294783) and PacBio (accession ERR1079227). The assembly of the plasmid from the PacBio data has accession LN890519.

The paper describing the full data set is here:
"A Phylogenetic and Phenotypic Analysis of Salmonella enterica Serovar Weltevreden, an Emerging Agent of Diarrheal Disease in Tropical Regions",
Carine Makendi, Andrew J. Page, et al. PLOS Neglected Tropical Diseases, 2016.
http://journals.plos.org/plosntds/article?id=10.1371/journal.pntd.0004446

Step 1 - Run Velvet Optimiser:
```
VelvetOptimiser.pl -s 66 -e 90 -t 1 -d velvet_optimiser_output -f '-shortPaired -fastq.gz -separate S.welt.10259.plasmid_1.fastq.gz S.welt.10259.plasmid_2.fastq.gz'
```
This takes less than 1 minute on a single CPU. When we ran it the assembly contained 99,037 bases in 5 contigs, however this can vary as there is some randomness in de novo assembly.

Step 2 - Run Assembly Improvement
```
improve_assembly -a velvet_optimiser_output/contigs.fa  -f S.welt.10259.plasmid_1.fastq.gz -r S.welt.10259.plasmid_2.fastq.gz -i 350 -o improved_output
```
This takes less than 1 minute on a single CPU. When we ran it the assembly contained 98,733 bases in a single contig. The PacBio assembly contains 98,756 bases.
The final assembly is contained in:
```
improved_output/contigs.fa.scaffolded.filtered
```

The example_output directory contains the assemblies that were produced at each stage.
