#!/usr/bin/env perl
package Bio::AssemblyImprovement::Bin::Abacas;
# ABSTRACT: Algorithm Based Automatic Contiguation of Assembled Sequences
# PODNAME: abacas.pl


# Copyright (C) 2008-11 Genome Research Limited. All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

#ABACAS.1.3.2
#--------------------------------
#Please report bugs to:
#sa4@sanger.ac.uk & tdo@sanger.ac.uk
 

use strict;
use warnings;
use POSIX qw(ceil floor);
use Getopt::Std;
our $version="1.3.2";
#-------------------------------------------------------------------------------

if (@ARGV < 1) { usage();}

my ($help, $reference, $query_file, $choice, $sen, $seed, $mlfas, $fasta_bin, $avoid_Ns,
   $tbx, $min_id, $min_cov, $diff_cov, $min_len,$add_bin_2ps, $pick_primer,
   $flank, $chk_uniq,$redoMummer, $is_circular,$escapeToPrimers, $debug, $gaps_2file, $prefix,$optionsLog,$numNs)
   =checkUserInput( @ARGV );

my $ref_inline; 
if ($escapeToPrimers ==1)
{
    pickPrimers ($reference, $query_file, $flank, $chk_uniq);
    exit;
}
#BEGIN
#-------------------------------------------------------------------------------
print_header();
print $optionsLog;

$ref_inline = Ref_Inline($reference);
#Get length of the reference sequence
my $ref_len =  length($ref_inline);


###################
# Running MUMmer   #
###################
my ($path_dir, $run_mum, $path_toPass);	
if ($debug)
{
    print "the seed is  $seed \n";
    print "RedoMummer= ",$redoMummer."\n";
}
my @do_mum_return;
my $mummer_tiling;
if ($redoMummer==0)
{
        print "#\tPREPARING DATA FOR   $choice \n";
        @do_mum_return = doMummer($reference, $query_file, $choice,$sen,$seed,$min_id, $min_cov, $diff_cov,$min_len, $debug, $is_circular) or die "Couldn't run MUMmer\n";
        $mummer_tiling = $do_mum_return[0];
        $path_dir = $do_mum_return[2];
        $path_toPass = $do_mum_return[1];

}
elsif ($redoMummer ==1)
{      print "not doing mummer\n";
       my @check = checkProg ($choice);
       $mummer_tiling = '$choice.tiling';
       $path_dir = $check[2];
       $path_toPass = $check[1];
}
else
{
        print "Unknown option for -R\n";
        exit;
}

####################################
# Processing tiling output         #
####################################
if ($debug) {
  print "Do tiling...\n";
}

#-------------------------------- 

##################
#Do Tiling
#-------------------------------------------
doTiling ($mummer_tiling, $path_toPass, $path_dir,$reference, $query_file, $choice, $prefix,$mlfas, $fasta_bin, $avoid_Ns, $ref_len, $gaps_2file, $ref_inline, $add_bin_2ps, $pick_primer, $flank, $chk_uniq, $tbx,$numNs);





############################################## SUB ROUTINES for CONTIG ORDERING and PRIMER DESIGN ##########################################################
# Put in one file for ease of downloading. They could be placed in separate packages.
#----------------------------------------------------------------------------------------------------------
#################################Contig ordering ##########################################################
######## 

sub help
{

die <<EOF 

***********************************************************************************
* ABACAS: Algorithm Based Automatic Contiguation of Assembled Sequences           *
*                                                                                 *
*                                                                                 *
*   Copyright (C) 2008-11 The Wellcome Trust Sanger Institute, Cambridge, UK.     *
*   All Rights Reserved.                                                          *
*                                                                                 *
***********************************************************************************

USAGE
abacas.pl -r <reference file: single fasta> -q <query sequence file: fasta> -p <nucmer/promer>  [OPTIONS]

	-r	reference sequence in a single fasta file
	-q	contigs in multi-fasta format
	-p	MUMmer program to use: 'nucmer' or 'promer'
OR
abacas.pl -r <reference file: single fasta>  -q <pseudomolecule/ordered sequence file: fasta> -e 
OPTIONS
        -h              print usage
	-d		use default nucmer/promer parameters 
	-s	int	minimum length of exact matching word (nucmer default = 12, promer default = 4)
	-m		print ordered contigs to file in multifasta format 
	-b		print contigs in bin to file 
	-N		print a pseudomolecule without "N"s 
	-i 	int 	mimimum percent identity [default 40]
	-v	int	mimimum contig coverage [default 40]
	-V	int	minimum contig coverage difference [default 1]
	-l	int	minimum contig length [default 1]
	-t		run tblastx on contigs that are not mapped 
	-g 	string (file name)	print uncovered regions (gaps) on reference to file name
	-n	int	insert n Ns between overlapping contigs [default 100]
	-a		append contigs in bin to the pseudomolecule
	-o	prefix  output files will have this prefix
	-P		pick primer sets to close gaps
	-f	int	number of flanking bases on either side of a gap for primer design (default 350)
        -R      int     Run mummer [default 1, use -R 0 to avoid running mummer]
	-e 		Escape contig ordering i.e. go to primer design
	-c 		Reference sequence is circular

EOF
}
########
sub usage
{

die <<EOF 
---------------------------------------------------------------------------------------------------

ABACAS.$version
visit www.abacas.sourceforge.net for more information.
--------------------------------
Please report bugs to:sa4 (at)sanger.ac.uk  and tdo (at) sanger.ac.uk
----------------------------------------------------------------------------------------------------

USAGE
abacas.pl -r <reference file: single fasta> -q <query sequence file: fasta> -p <nucmer/promer>  [OPTIONS]
	-r	reference sequence in a single fasta file
	-q	contigs in multi-fasta format
	-p	MUMmer program to use: 'nucmer' or 'promer'
for contig ordering and  primer design

OR
abacas.pl -r <reference file: single fasta>  -q <pseudomolecule/ordered sequence file: fasta> -e 
to escape contig ordering and go directly to primer design

OR
abacas.pl -h  for help

EOF
}
########
##################
sub print_header
{
    print "
***********************************************************************************
* ABACAS: Algorithm Based Automatic Contiguation of Assembled Sequences           *
*                                                                                 *
*                                                                                 *
*   Copyright (C) 2008-11 The Wellcome Trust Sanger Institute, Cambridge, UK.     *
*   All Rights Reserved.                                                          *
*                                                                                 *
***********************************************************************************
\n";
}
#########################################
sub checkUserInput{
    my %options;
    getopts('hr:q:p:ds:mbNi:v:V:l:n:tg:ao:Pf:Ru:ecD', \%options);
    my $optionsLog="#  Checking user options:";
     my ($help, $reference, $query_file, $choice, $sen, $seed, $mlfas, $fasta_bin, $avoid_Ns,
        $tbx, $min_id, $min_cov, $diff_cov, $min_len,$add_bin_2ps, $pick_primer,
        $flank, $chk_uniq,$redoMummer, $is_circular,$escapeToPrimers, $debug, $gaps_2file, $prefix);
    
    if($options{h}) {
        $help = $options{h};
        help();
    }
    if ($options{r} && $options{q} ){
        ($reference, $query_file) = ($options{r},$options{q});
        $optionsLog.="\n#\t-r Reference=$reference\n#\t-q Query=$query_file\n";
    }else{
        usage() unless $options{e};
    }
    
    if ($options{p}){
        $choice =  $options{p};
	$optionsLog.="#\t-p $choice\n";
        unless ($choice eq "nucmer" || $choice eq "promer"){
        print "Unknown MuMmer function\n Please use nucmer or promer\n";
        exit;
        }
    }else{
        usage() unless $options{e};
    }
    if ($options{e}){ #$escapeToPrimers)
        print_header(); 
        print "Primer design selected,... escaping contig ordering\n";
        $escapeToPrimers = 1;
        $chk_uniq = "nucmer";
        $choice = "";
	$optionsLog.="#\t-e Primer design selected,... escaping contig ordering\n";
    }else{
        $escapeToPrimers = 0;
    }
    if ($options{d}) {
	$sen =1;
	$optionsLog.="#\t-d use default setting i.e. --mumreference in $choice\n";
    } else {
	$sen =0;
	$optionsLog.="#\t-d 0 use sensitive mapping in $choice i.e. --maxmatch\n";
	} #print $sen , " ---sen\n";
    #print $options{t}, "\n"; exit;
    if($options{t}) {$tbx = 1;} else {$tbx = 0;}   #print $tbx, " ---tbx\n"; #
    if ($options{s}){
	$seed = $options{s};
	$optionsLog.="#\t-s seed=$seed\n";
    }
    else{
        if ($choice eq "nucmer"){
            $seed = 12;
        }
        else{
            $seed =4;
        }
	
    }
    if ($options{m}){
	$mlfas =1;
	$optionsLog.="#\t-m  print multifasta file of ordered contigs\n"
    } else { $mlfas =0; } #print $mlfas , " ---mlfasta\n";
    if ($options{b}) {
	$fasta_bin =1;
	$optionsLog.="#\t-b  print multifasta file of contigs in bin to file\n"   
    } else {$fasta_bin =0;}
    if ($options {N}){
	$avoid_Ns =1;
	$optionsLog.="#\t-N  don't print Ns in pseudo-molecule\n"
    } else {$avoid_Ns=0;}
    
    if($options{i}){
	$min_id=$options{i};
	$optionsLog.="#\t-i $min_id is the minimum identity cutoff\n";
    }	
    else{$min_id =40;
	# $optionsLog.="#\t-i not defined: $min_id is the default minimum identity cutoff\n";
    }
    if ($options{v}){
	$min_cov = $options{v};
	$optionsLog.="#\t-v $min_cov is the minimum contig-coverage cutoff\n";
    }
    else{
	$min_cov =40;
	#$optionsLog.="#\t-v not defined $min_id is the default contig-coverage cutoff\n";
    }
    if($options{V}){
	$diff_cov = $options{V};
	$optionsLog.="#\t-V $diff_cov\n";
    }
    else {$diff_cov =1;
	 # $optionsLog.="#\t-V $diff_cov using the default value\n";
    }
    if ($options {l}){
	$min_len = $options {l};
	$optionsLog.="#\t-l $min_len is the minimum length of contigs to be ordered\n";
    }
    else{$min_len = 1;
	# $optionsLog.="#\t-l not defined: using 1 as the default minimum length of contigs to be ordered\n";
    }
    if ($options{a}) {$add_bin_2ps = 1; }else {$add_bin_2ps =0;}
    if ($options{P}) {$pick_primer=1;} else {$pick_primer =0;}
    if ($options{f}) {$flank = $options{f};} else {$flank = 1000;}
    if ($options{u}) {$chk_uniq = $options{u}; } else {$chk_uniq = "nucmer";}
        
        #unless ($options{R}) {$re}
    if($options{R}) {$redoMummer = 1; } else {$redoMummer = 0;}

    if($options{c}) {$is_circular = 1;}else {$is_circular =0;}
    if ($options{g}) {$gaps_2file = $options{g};} else {$gaps_2file ="";}
    if($options{o}) {$prefix = $options{o};} else {$prefix = "";}
    if ($options {n}) {$numNs =$options{o};} else{$numNs=100;}
    if($options{D}){
	$debug=1;
	$optionsLog.="#\t-D debug\n";
    }
    else {$debug =0};
    if ($tbx ==1 && $fasta_bin !=1)
    {
	print "ERROR:  Please use  -t -b  if you want to run tblastx on contigs in bin\n";
	exit;
    } 
   # print $redoMummer , "\n"; exit;
   
    $optionsLog.="#\tInput checking done!!\n";
    #print $optionsLog;
    return ($help, $reference, $query_file, $choice, $sen, $seed, $mlfas, $fasta_bin, $avoid_Ns,
        $tbx, $min_id, $min_cov, $diff_cov, $min_len,$add_bin_2ps, $pick_primer,
        $flank, $chk_uniq,$redoMummer, $is_circular,$escapeToPrimers, $debug, $gaps_2file, $prefix,$optionsLog,$numNs);    
    
} ## end of checkUserInput
#############
## get the reference sequence in one line
#--------------------------------------------------
sub Ref_Inline
{
	my $ref = shift;
	open (refFH, $ref) or die "Could not open file $ref\n";
	my $seq ="";
	my @r = <refFH>;
        my $num_chr =0;
        foreach(@r){
            if ($_ =~ /\>/){
                $num_chr +=1;
            }
        }
        if ($num_chr > 1){
            print "\nERROR: Please use a single fasta reference file. You can simply merge chromosomes in to a union fasta file.\n\n";
            exit;
        }
	shift @r;
	foreach(@r){
	    chomp;
	    $seq = $seq.$_;
	}
	return $seq;	
}
################
# Run mummer
#--------------------------------------------
sub doMummer
{
    my ($reference, $query_file, $choice, $sen,$seed,$min_id, $min_cov, $diff_cov,$min_len, $debug, $is_circular ) = @_;

    my $df = 'delta-filter';
    my $st = 'show-tiling';
    my $ask = 'which';
    my ($path_toPass, $run_mum); # params to return...
    my ($command, $Path, $dir) = checkProg($choice);
    my ($run_df, $df_path, $df_dir) = checkProg($df);
    my ($run_st, $st_path, $st_dir) = checkProg($st);
    my (@running, @deltaRes, @coordsRes);
    if ($choice eq "nucmer")
    {
	if ($sen ==0)
	{
	    @running = `$command --maxmatch -l $seed -p $choice $reference $query_file &> /dev/null`;
	    @deltaRes = `$run_df -q $choice.delta >$choice.filtered.delta`;
	    if ($is_circular == 1)
	    {
		@coordsRes = `$run_st -c -i $min_id -v $min_cov -V $diff_cov -l $min_len -R -u unused_contigs.out $choice.filtered.delta > $choice.tiling`;
	    }
	    else
	    {
		@coordsRes = `$run_st -i $min_id -v $min_cov -V $diff_cov -l $min_len -R -u unused_contigs.out $choice.filtered.delta > $choice.tiling`;
		
	    }
	}
	else
	{
	    @running = `$command -p $choice $reference $query_file &> /dev/null`;
	    @deltaRes = `$run_df -q $choice.delta >$choice.filtered.delta`;
	    if ($is_circular ==1) {@coordsRes = `$run_st -c -i $min_id -v $min_cov -V $diff_cov -l $min_len -R -u unused_contigs.out $choice.filtered.delta > $choice.tiling`;}
	    else { @coordsRes = `$run_st -i $min_id -v $min_cov -V $diff_cov -l $min_len -R -u unused_contigs.out $choice.filtered.delta > $choice.tiling`;}
	}
	
    }
    else
    {
	if ($sen ==0)
	{
	    @running = `$command  --maxmatch -l $seed -x 1 -p $choice $reference $query_file &> /dev/null`;
	    @deltaRes = `$run_df -q $choice.delta >$choice.filtered.delta`;
	    if ($is_circular == 1)
	    {
		@coordsRes= `$run_st -c -i $min_id -v $min_cov -V $diff_cov -l $min_len -R -u unused_contigs.out $choice.filtered.delta > $choice.tiling`;
	    }
	    else
	    {
		@coordsRes= `$run_st -i $min_id -v $min_cov -V $diff_cov -l $min_len -R -u unused_contigs.out $choice.filtered.delta > $choice.tiling`;
	    }
	}
	else
	{
	    @running = `$command -l $seed -p $choice $reference $query_file &> /dev/null`;
	    @deltaRes = `$run_df -q $choice.delta >$choice.filtered.delta`;
	    if ($is_circular == 1) {
		@coordsRes= `$run_st -c -i $min_id -v $min_cov -V $diff_cov -l $min_len -R -u unused_contigs.out $choice.filtered.delta > $choice.tiling`;
	    }
	    else
	    {
		@coordsRes= `$run_st -i $min_id -v $min_cov -V $diff_cov -l $min_len -R -u unused_contigs.out $choice.filtered.delta > $choice.tiling`;
	    }
	}
    }
    my $Coordsfull= "$choice.tiling";
    return ($Coordsfull,$Path, $dir);
}
 
## #############################################################################
sub checkProg{ #checks if a given excutable is in the path...
    my $prog = shift;
    my $ask = 'which';
    my @check_prog = `$ask $prog`;
    my $path_toPass;
    my $path_dir;
    my $command;
    if (defined $check_prog[0] && $check_prog[0] =~ /$prog$/)
    {
	$path_toPass = $prog;
	$command = $prog;
    }
    else
    {
	print "\nENTER the directory for your ", $prog, " executables [default ./]:  ";
        my $path=<STDIN>;
        chomp $path;
	$path_dir = $path;
	if ($path_dir =~/\/$/)
	{
	    $path_dir = $path_dir;
	}
	else
	{
	    $path_dir = $path_dir."/";
	}
	my @final_check = `$ask $command`;
	if (exists $final_check[0] && $final_check[0] =~ /$prog$/)
	{
	    $command = $path_dir.$prog;
	    $path_toPass = $command;   
	}
	else
	{
	   print "ERROR: Could not run  ", $prog, ", please check if it is installed in your path\n or provide the directory \n";
	   exit; 
	}
    }
    
    return ($command, $path_toPass, $path_dir);
}

##############################
# converts a fasta file to an ordered single line
#--------------------------------------------------
sub Fasta2ordered
{
	if(  @_ != 1 )
	{
		print "Usage: Fasta2ordered <fasta_file>\n";
		exit;
	}
	my $fast = shift; #print $fast; exit;
	my @fasta = split (/\n/, $fast);
	if ($fasta[0] =~ /\>/ ) #remove chromosome name if exists in the onput sequence.
	{
        	my $ch_name = $fasta[0];
        	shift @fasta;
	}
	#print $fasta[0]; exit;
	foreach(@fasta){chomp;}
	my $num_lines = scalar(@fasta);
	my $dna = '';
	for(my $i=0; $i< $num_lines; $i+=1)
	{
                $dna = $dna.$fasta[$i]; 
	}
	my $ordered_dna = $dna;
	return $ordered_dna;
}
##############################################################
# Hash input contigs
#------------------------------------------------

sub hash_contigs {
  if(  @_ != 1 )
	{
	  print "Usage: hash_contigs contigs_file";
	  exit;
	}
  my $contigs_file = shift;
  if( $contigs_file =~ /\.gz$/ )
	{
	  open(CONTIGS, $contigs_file, "gunzip -c $contigs_file |" ) or die "Cant open contigs file: $!\n";
	}
  else
	{
	  open( CONTIGS, $contigs_file) or die "Cant open contigs file: $!\n";
	}
  
  my %contigs_hash; # hash to store contig names and sequences
  my $contigName;
  
  
  while (<CONTIGS>) ##add error checking...
	{
	  if (/^>(\S+)/) {
		$contigName=$1;
	  }
	  else {
		chomp;
		$contigs_hash{$contigName} .= $_;
	  }
	}
  close(CONTIGS);
  #tdo
  ## check if qual exists
  my %contigs_qual_hash;
  
  
  if (-r "$contigs_file.qual" or -r "$contigs_file.qual.gz") {
	if( -r "$contigs_file.qual.gz" )
	  {
		open(CONTIGS, "$contigs_file.qual.gz", "gunzip -c $contigs_file.qual.gz |" ) or die "Cant open contigs file: $!\n";
	  }
	else
	  {
		open( CONTIGS, "$contigs_file.qual" ) or die "Cant open contigs file: $!\n";
	  }
	
	
	while (<CONTIGS>) {
	  if (/^>(\S+)/) {
		$contigName=$1;
	  }
	  else {
		chomp;
		$contigs_qual_hash{$contigName} .= $_;
	  }
	}
	
  } # end tdo # end if exist 
  
  
  return (\%contigs_hash,\%contigs_qual_hash);
}
#######################
##############################
### it gets a delta name
sub getMummerComparison{
  my $deltaName = shift;


  ### transform the delta file to coords
  my $call ="show-coords -H  -T -q  $deltaName >  $deltaName.coords ";
  !system(" $call") or die "Problems doing the show-coords comparison: $call $!\n";


  ### willh old results
  my %h;

  ### has as index the postion with the max hits
  my %h_max;
  my $tmp=0;
  my $tmp_index;
  my $key='';
  my $is_promer =0;
  if ($deltaName =~/^promer/)
  {
     $is_promer =1;
  }
  
  open (F,"$deltaName.coords") or die "Problem in getComparisonFile to open file $deltaName.coords\n";
  my @File=<F>;
  my @a;
  @a=split(/\s+/,$File[0]);
  $tmp=$a[5];
  $tmp_index=$a[0];
  if ($is_promer ==1)
  {
    $key=$a[12]; ## nucmer:  $key = $a[8]
  }
  else
  {
    $key = $a[8];
  }
  
  foreach (@File) {
	@a=split(/\s+/);
        
        if ($is_promer ==1)
        {
            push @{ $h{$a[12]}}, "$a[12]\t$a[11]\t$a[7]\t$a[5]\t0\t0\t$a[2]\t$a[3]\t$a[0]\t$a[1]\t1\t$a[5]\n";
            if ($key eq $a[12] and $a[5]>$tmp)
            {
              $tmp=$a[5];       # length
              $tmp_index=$a[0]; # position reference
            }
            elsif ($key ne $a[12]) {
              ### here possible bugg...
              $h_max{$tmp_index}=$key;
              $key=$a[12];
              $tmp=$a[5];       # length
              $tmp_index=$a[0]; # position reference
              
            }
        } #end if
        #else i.e. if nucmer
        else
        {
            push @{ $h{$a[8]}}, "$a[8]\t$a[6]\t$a[6]\t$a[5]\t0\t0\t$a[2]\t$a[3]\t$a[0]\t$a[1]\t1\t$a[5]\n";
            if ($key eq $a[8] and $a[5]>$tmp)
            {
              $tmp=$a[5];       # length
              $tmp_index=$a[0]; # position reference
            }
            elsif ($key ne $a[8]) {
              ### here possible bugg...
              $h_max{$tmp_index}=$key;
              $key=$a[8];
              $tmp=$a[5];       # length
              $tmp_index=$a[0]; # position reference
              
            }
        }
        
  }
  $h_max{$tmp_index}=$key;
#  print Dumper %h_max;
  
  return (\%h,\%h_max);
}
##################################
###########################
sub writeBinContigs2Ref{
  my $nameBin = shift;
  my $name    = shift;
  
  open (F, "$nameBin") or die "Couldn't find file $nameBin: $!\n";
  
  my @ar;

  my $count=0;
  
  while (<F>) {
	push @ar, $_;
	$count++;
  }
    #### sa4: added error checking:- if file is empty
    if (scalar(@ar) < 1)
    {
        print "No contigs in unusedcontigs file\n";
        $count = 0;
        
    }
    else
    {
        open (F, "> $name.notMapped.contigs.tab") or die "Couldn't write file $name.tab: $!\n";
        print F doArt(\@ar);
        close(F);
    }
    return $count;
  
}


##############################
sub doArt{
  my ($ref) = @_;


  ## hash of array with all positions of the contig
  my %Pos;

  ## Hash with note of result line of nucmer
  my %lines;

  foreach (@$ref) {
	chomp;
	my @ar=split(/\t/);
	push @{ $Pos{$ar[12]}}, "$ar[0]..$ar[1]";
	$lines{$ar[12]} .= "FT                   $_\n";
  }

  my $res;
  
  foreach my $contig (keys %lines) {
	
	if (scalar(@{ $Pos{$contig} } >1)) {
	  my $tmp;
	  
	  foreach (@{ $Pos{$contig} }) {
		$tmp.="$_,";
	  }
	  $tmp =~ s/,$//g; # get away last comma
	  $res .= "FT   contig          join($tmp)\n";
	}
	else {
	  $res .= "FT   contig          $Pos{$contig}[0]\n";
	}
	$res .=   "FT                   /systematic_id=\"$contig\"\n";
	$res .=   "FT                   /note=\"Contig $contig couldn't map perfectly.\n";
	$res .= $lines{$contig};
	$res .= "FT                   \"\n";
	
  }

  return $res;
}

##########################################################################
#---------------------------
sub makeN #creates a string of Ns
{
	my $n = shift;
	my $Ns= "N";
	for (my $i =1; $i < $n; $i+=1)
	{
		$Ns = $Ns."N";
	}
	return $Ns;
}

###########################################################################
## reverse complement a sequence
#---------------------------------------------
sub revComp {
  my $dna = shift;
  my $revcomp = reverse($dna);

  $revcomp =~ tr/ACGTacgt/TGCAtgca/;

  return $revcomp;
}
####
#### basic stats 
sub getAM{
    my @array = @_;
    return undef unless(scalar(@array));
    my $sum =0;
    my $siz = scalar(@array);
    foreach (@array){
        $sum = $sum + $_;
    }
    my $Amean = sprintf("%.2f",($sum/$siz));
    return $Amean;
}

sub getMedian{
    my @arr = @_;
    return undef unless(scalar(@arr));
   my $median;
    my @array  = sort {$a<=> $b} @arr;
    my $siz = scalar(@array);
  if ($siz%2==1){# $number is odd
	    $median = $array[($#array / 2)];
	}
	else{    # $number is even
	    
	   $median = $array[int($#array / 2)] + (($array[int($#array / 2) + 1] - $array[int($#array / 2)]) / 2); 
	}
    return $median;
}

sub get_SD
{
    my(@numbers) = @_;
    return undef unless(scalar(@numbers));
# Step 1, find the mean of the numbers
    my $total1 = 0;
    foreach my $num (@numbers) {
    $total1 += $num;
    }
    my $mean1 = $total1 / (scalar @numbers);

    # Step 2, find the mean of the squares of the differences
    # between each number and the mean
    my $total2 = 0;
    foreach my $num (@numbers) {
    $total2 += ($mean1-$num)**2;
    }
    my $mean2 = $total2 / (scalar @numbers);

    # Step 3, standard deviation is the square root of the
    # above mean
    my $std_dev = sprintf("%.2f",(sqrt($mean2)));
    return $std_dev;
}
sub getMin {
        my @array = @_;
	return undef unless(scalar(@array));
        my @sorted = sort {$a<=> $b} @array;
        my $min = $sorted[0];
    return $min;
}
sub getMax {
        my @array = @_;
	return undef unless(scalar(@array));
        my @sorted = sort {$a<=> $b} @array;
        my $siz = scalar(@sorted);
        my $max = $sorted[$siz -1];
    return $max;
}

sub getN50 {
    my @array = @_;
    my $totLen=0;
    foreach (@array){
	chomp;
	$totLen+=$_;
    }
    my @sort = sort {$b <=> $a} @array;
    my $n50; 
    foreach my $val(@sort){
     $n50+=$val;
      if($n50 >= $totLen/2){
         return ($totLen, $val);
         last; 
     }
    }
}

################################################################################
### function to visualize rep. regions in Reference genome.
sub findRepeats
{
    my $reference        = shift;
    my $name             = shift;
    my $path_prog        = shift;
    
    # get path
    my ($path_coords) = $path_prog;
    
    $path_coords =~ s/nucmer/show-coords/;
    
    my $call = "$path_prog --maxmatch -c 100 -b 40 -p $name.repeats -l 25 $reference $reference  &> /dev/null ";
    !system("$call") or die "Problems doing the nucmer comparison: $call $!\n";
    $call ="$path_coords -r -c -l  $name.repeats.delta >  $name.repeats.coords ";
    !system(" $call") or die "Problems doing the show-coords comparison: $call $!\n";
    
    my @Res;
    open (F, "$name.repeats.coords" ) or die "Problems to open file $reference.repeats.coords: Is MUMmer installed correctly and inserted in the PATH environment variable? ($!)\n";
    $_=<F>; $_=<F>; $_=<F>; $_=<F>;$_=<F>;
    while (<F>) {
          my @ar = split(/\s+/);
          if (!($ar[1] == $ar[4] or $ar[2] == $ar[5] or $ar[7] > 100000)) { # to exclude self alignment
            
            foreach ($ar[1]..$ar[2]) {
                  $Res[($_-1)]++;
            }
          }
    }
    
    ### write the result to the plot file
    
    my $res;
    foreach (@Res){
          if (defined($_)) {
            $res .= "$_\n";
          }
          else {
            $res .= "0\n";
          }
    }
    
    open (F, "> $name.Repeats.plot") or die "Couldn't open file $name.plot to write: $! \n";
    print F $res;
    close(F);
    
    ### delete files
    unlink("$name.repeats.delta");
    unlink("$name.repeats.coords");
    unlink("$name.repeats.cluster");
}

################################################################################
# reverse a list of qualities
#------------------------------
sub reverseQual{
  my $str = shift;

  $str =~ s/\s+$//g;
  
  my @ar = split(/\s/,$str);
  my $res;
  
  for (my $i=(scalar(@ar)-1);$i>=0;$i--) {
	$res.="$ar[$i] ";
  }
  return $res;
}

##############################################################################
# ----------------
sub getPosCoords{
  my $ref_ar = shift;
  my $contig = shift;
  
  my $offset = shift;
  my $res;
  #  print Dumper $$ref_ar{$contig};
  foreach (@{$$ref_ar{$contig}}) {
	print "in getPos Coords: $_\n";;
	
	my @ar=split(/\t/);
	$ar[6]+=$offset;
	$ar[7]+=$offset;
	$res .= join("\t",@ar);;
  }
  
  return $res;
  
}
#############################################################################
# -----------------------------
sub getPosCoordsTurn{
  my $ref_ar = shift;
  my $contig = shift;
  
  my $offset = shift;
  
  
  my $res;
  
  #  print Dumper $$ref_ar{$contig};
  foreach (@{$$ref_ar{$contig}}) {
	my @ar=split(/\t/);
	my $tmp_8=$ar[8];
	my $tmp_9=$ar[9];
	
	$ar[8]=$ar[6]+$offset;
	$ar[9]=$ar[7]+$offset;
	$ar[6]=$tmp_8;
	$ar[7]=$tmp_9;
	
	## change query subject
	
	$res .= join("\t",@ar);;
  }
  
  return $res;
  
}

############################################################################
#------------------------
sub printStats{
    
  my ($num_fortillingcontigs,$num_notsetTilling,$num_mapped, $num_contigs, $num_inComparisoncontigs, $ref_len, $total_bases_mpd) = @_;
  $num_fortillingcontigs=$num_notsetTilling+$num_mapped;
  my $res;
  $res.= "Short statistics of run.\n";
  $res.= "$num_contigs\t\tcontigs entered to be mapped against the reference.\n";
  $res.= sprintf("$num_inComparisoncontigs\t%0.2f \%\tmade a hit against the reference to the given parameter (-s -d etc)\n",($num_inComparisoncontigs*100/$num_contigs));
  $res.= sprintf("$num_fortillingcontigs\t%0.2f \%\twere considered for the tilling graph (-s -d etc)\n",($num_fortillingcontigs*100/$num_contigs));
  $res.= sprintf("$num_mapped\t%0.2f \%\tare mapped in the tilling graph (-s -d etc)\n",($num_mapped*100/$num_contigs));
  $res.= sprintf("\nCoverage: The reference is $ref_len long. Up to $total_bases_mpd bp (%0.2f \%) are covered by the contigs (This doesn't mean that these regions are really similar...)\n",($total_bases_mpd*100/$ref_len));

  print $res;
  
}
##################################################
#### Do Tiling
#----------------------------------------------------
sub doTiling {
    
    my ($mummer_tiling, $path_toPass, $path_dir,$reference, $query_file, $choice, $prefix,
	$mlfas, $fasta_bin, $avoid_Ns, $ref_len, $gaps_2file, $ref_inline, $add_bin_2ps,
	$pick_primer, $flank, $chk_uniq, $run_blast, $numNs) = @_;
    
    ### these are also defined in the main script.... to be changed!!
    my ($num_contigs , $num_inbincontigs, $avg_cont_size,$num_overlaps , $num_gaps,
    $num_mapped,$total_bases_mpd,$p_ref_covered,$num_ambigus,$num_inComparisoncontigs,
    $num_fortillingcontigs,$num_notsetTilling)= (0,0,0,0,0,0,0,0,0,0,0,0);
    
    my ($href, $ref_contigs_qual) = hash_contigs($query_file);
    my $qualAvailable=0;
    my %contigs_hash = %{$href};
    my @c_keys = keys %contigs_hash;
    $num_contigs = scalar(@c_keys);
    my @cont_lens;
    my (@ids ,$id, $id_len);
    my (@Rs, @Re, @G, @Len, @cov, @pid, @orient, @Cid);
    my (@Ps, @Pe);
    my ($total);
    my $g; #define gap size between contigs
    my $tiling_gap; #gap size from tiling graph
    open (TIL, $mummer_tiling) or die "Could not open $mummer_tiling: $!";
    while (<TIL>)
    {
            chomp;
            if ($_ =~/^>/)
            {
                    my $line = substr $_, 1;
                    my @splits = split /\s+/, $line;
                    $id = $splits[0];
                    push @ids, $id;
                    $id_len= $splits[1];
            }
            else 
            {
                    my @splits = split /\s+/, $_;
                    push @Rs, $splits[0];
                    push @Re, $splits[1];
                    push @G, $splits[2];
                    push @Len, $splits[3];
                    push @cov, $splits[4];
                    push @pid, $splits[5];
                    push @orient, $splits[6];
                    push @Cid, $splits[7];
            }
            
    }
    close (TIL);
    if (scalar(@Rs) != scalar(@Re))
    {
            print "ERROR: unequal array size\n";
            exit;
    }
    else
    {
            $total = scalar(@Rs);
            $num_mapped = scalar(@Rs);      
    }
    my $ref_loc = $reference;  # get locations of reference and query files
    my $qry_loc = $query_file;
    my $dif_dir =0; 	#assume query and reference are in the working directory
    my @splits_reference = split (/\//, $reference);
    my $new_reference_file = $splits_reference[(scalar(@splits_reference)-1)];
    my @splits_query = split (/\//, $query_file);
    my $new_query_file = $splits_query[(scalar(@splits_query)-1)];
    if ($prefix eq "")
    {
        $prefix = $new_query_file."_".$new_reference_file;
    }
    #-------------------------------------------------------------------
    #define file handles for output files and open files to write output
    #-------------------------------------------------------------------
    my ($seqFH,$tabFH,$binFH,$crunchFH, $gapFH, $gapFHT,$gapFHS,@gap_sizes,$mlFH, $dbinFH, $avoidNFH,$ref_gapsFH);
    open ($seqFH, '>', $prefix . '.fasta') or die "Could not open file $prefix.fasta for write: $!\n";
    open ($tabFH, '>', $prefix . '.tab') or die "Could not open file $prefix.tab for write: $!\n";
    open ($binFH, '>', $prefix . '.bin') or die "Could not open file  $prefix.bin for write: $!\n";
    open ($crunchFH, '>', $prefix . '.crunch') or die "Could not open file $prefix.crunch for write: $!\n";
    open ($gapFH, '>', $prefix . '.gaps') or die "Could not open file $prefix.gaps for write: $!\n";
    open ($gapFHT, '>', $prefix . '.gaps.tab') or die "Could not open file $prefix.gaps.tab for write: $!\n";
    open ($gapFHS, '>', $prefix . '.gaps.stats') or die "Could not open file $prefix.gaps.stats for write: $!\n";
    my $num_ov=0;
    if ($mlfas ==1)
    {
        open ($mlFH, '>', $prefix . '.MULTIFASTA.fa') or die "Could not open file $prefix.contigs.fas for write: $!\n";	
    }
    if ($fasta_bin ==1)
    {
        open ($dbinFH, '>', $prefix . '.contigsInbin.fas') or die "Could not open file $prefix.contigsInbin.fas for write: $!\n";
    }
    if ($avoid_Ns ==1)
    {
        open ($avoidNFH, '>', $prefix .'.NoNs.fasta') or die "Could not open file $prefix.NoNs.fasta for write: $!\n";
    }
    if ($gaps_2file ne "")
    {
        open ($ref_gapsFH, '>', $gaps_2file.'.Gaps_onRef') or die "Could not open file $gaps_2file.Gaps_onRef for write: $!\n";
    }
    #-------------------------------------------------------------------------
    # Writing tiling graph and generating a pseudomolecule
    # Note use use ps for pseudomolecule
    #@Ps = start of ps, and @Pe = end of ps
    my $ps_start =1;
    $Ps[0] = 1; 
    $Pe[0] = $Ps[0] + $Len[0] -1;
    my $tmp_qual;
    my $tmp_nqual;
    my $tmp_seq ="";
    my $tmp_nseq ="";
    print "#\tOrdered contigs = $total \n";
    
    #------------------------------------------------------------
    # The 'for loop' loops over each contig in the Tiling output
    #Writing to file is done for each contig to speed up the process
    #This part could potentially be a separate subroutine
    
    print $tabFH "ID   ",$id, "\n";
    print $seqFH ">", "ordered_", $id, "\n";
    print $gapFHT "ID   ",$id, "\n";
    
     for (my $i=1; $i <= $total; $i+=1)
    {
        my $covv =sprintf("%.0f",$cov[$i -1]); #ROUNDING
        my $pidd = sprintf("%.0f", $pid[$i -1]);
        my ($contig_coord, $color, $contig_seq);
        my $contig_qual='';
        $tiling_gap = $G[$i -1];
        if ($tiling_gap <= 1){ #insert 100Ns for overlaps and gaps of size less than or equal to one base 
            $g = $numNs; # default gap size to 
        }
        else{
            $g = $tiling_gap; 
        }
        if (defined($Len[$i]))
	{
		  $Ps[$i] =  $Pe[$i-1] +$g +1;
		  $Pe[$i] = $Ps[$i] + $Len[$i] -1;
		  $total_bases_mpd+=$Len[$i];
	}
        
        if ($Rs[$i -1] <0) #check if a reference starting position is less than 0
	{
            $Rs[$i -1] =1;
	}
        
        if($orient[$i-1] eq "+")
        {
            $contig_coord = $Ps[$i -1]."..".$Pe[$i-1];
            $color = 4;
            $contig_seq = $contigs_hash{$Cid[$i-1]};
        }
        else
        {
            $contig_coord = "complement(".$Ps[$i -1]."..".$Pe[$i-1].")";
	    $color =3;
	    $contig_seq = revComp($contigs_hash{$Cid[$i-1]}); #REVERSE COMPLEMENT A SEQUENCE
            
        }
        push (@cont_lens, length($contig_seq));
        
        # tdo
        if (defined($$ref_contigs_qual{$Cid[$i-1]})) {
            ## flag to know, that the qual exists
            $qualAvailable=1;
            $contig_qual = $$ref_contigs_qual{$Cid[$i-1]};
        }
        $tmp_qual .= $contig_qual;
        $tmp_seq .= $contig_seq;
        if ($avoid_Ns ==1)
        {
            $tmp_nseq.= $contig_seq;
            #tdo
            $tmp_nqual .= $contig_qual;
        }
        if ($mlfas ==1)
        {
            my $multifasta_seq = write_Fasta ($contig_seq);
            print $mlFH ">", $Cid[$i-1], "\n", $multifasta_seq;
        }
        if ($Re[$i -1] > $ref_len)
	{
		$Re[$i -1] = $ref_len -1;
	}
	if ($Pe[$i -1] > length($tmp_seq))
	{
		$Pe[$i -1] = length($tmp_seq);
	}
        
        #-----------------------------------------
        print $crunchFH $covv, " ", $pidd, " ", $Ps[$i -1], " ", $Pe[$i -1], " ", $Cid[$i -1], " ", $Rs[$i -1], " ", $Re[$i-1], " ", "unknown NONE\n";
	
        #WRITE FEATURE FILE
	print $tabFH "FT   contig          ",$contig_coord, "\n";
	print $tabFH "FT                   ", "/systematic_id=\"", $Cid[$i-1],"\"","\n";
	print $tabFH "FT                   ", "/method=\"", "mummer\"", "\n";
        print $tabFH "FT                   ", "/Contig_coverage=\"",$cov[$i -1], "\"", "\n";
        print $tabFH "FT                   ", "/Percent_identity=\"",$pid[$i -1], "\"", "\n";
        my ($gap_coord, $gapCol,$gap_start,$gap_end,$ref_start, $ref_end) ;
	
	
            $gap_start = $Pe[$i -1] +1;
            if (defined $Ps[$i])
            {
                $gap_end = $Ps[$i] -1;
            }
	    else
	    {
		$gap_end = $gap_start + ($g) -1 ; ############ ...... check.....
	    }
            $ref_start = $Re[$i -1] +1;
          
            if (defined $Rs[$i])
            {
                $ref_end =$Rs[$i]-1;
            }
            else
            {
                $ref_end = "END";
            }
	$gap_coord = $gap_start."..".$gap_end;
	my $ov ="";
	
	if ($tiling_gap > 1)       #WRITE GAP LOCATIONS AND SIZE TO FILE
	{   
            print $gapFH "Gap\t",$tiling_gap, "\t", $gap_start, "\t", $gap_end, "\t", $ref_start, "\t", $ref_end,"\tNON-Overlapping\n";
            $ov = "NO";
	    $gapCol = 8;
	    push @gap_sizes, $g; 
	    if ($gaps_2file ne "" && $ref_start < $ref_len)
	    {
                    my $gapOnref = substr ($ref_inline, $ref_start, $g);
		    print $ref_gapsFH ">StartOnRef_",$ref_start, "   [Gap=",$g,"]\n";
                    my $file_toPrint = write_Fasta ($gapOnref);
                    print $ref_gapsFH $file_toPrint;
            }
        }
        else
        {
            $color = 5;
	    $gapCol =9;
	    $ov ="YES";
	    $num_ov+=1;
	    print $gapFH "Gap\t",$g, "\t", $gap_start, "\t", $gap_end, "\t", $ref_start, "\t", $ref_end,"\tOverlapping\n";
	    print $tabFH "FT                   ", "/Overlapping=\"", "YES\"", "\n";
	}
	
	print $gapFHT "FT   GAP             ",$gap_coord, "\n";
	print $gapFHT "FT                   ", "/SIZE=\"", $g,"\"","\n";
	print $gapFHT "FT                   ", "/Overlapping=\"", $ov, "\"","\n";
	print $gapFHT "FT                   ", "/colour=\"",$gapCol, "\"", "\n";
	print $tabFH  "FT                   ", "/colour=\"",$color, "\"", "\n";    
	
        my $ns = makeN($g);
        $tmp_seq = $tmp_seq.$ns;
        #tdo
        for (1..length($ns))
	{
	    $tmp_qual .= "0 ";
        }
        
    }
    ## get gap stats...
    my $realGaps = scalar(@gap_sizes);
    print $gapFHS "$num_ov  Gaps introduced because of overlaps\n";
    print $gapFHS "$realGaps Real_gaps found\n#### Stats on real gaps\n";
    
    if ($realGaps >0)
    {
	my $minG = getMin(@gap_sizes);
	my $maxG = getMax(@gap_sizes);
	my $medG = getMedian(@gap_sizes);
	my ($sum, $n50) = getN50(@gap_sizes);
	print $gapFHS "Min. gap size is $minG\nMax. gap size is $maxG\nMedian gap size is $medG\nSum of gaps is $sum\nN50 gap size is $n50\n";
    }
    #------------------------------------------------------------------
    #tdo
    my @Quality_Array;
    if ($qualAvailable) {
        @Quality_Array = split(/\s/,$tmp_qual);
        my $res;
        foreach (@Quality_Array) {
            $res .= "$_\n";
        }
        ## get name
        my @splits_query = split (/\//, $query_file);
        $new_query_file = $splits_query[(scalar(@splits_query)-1)];
        open (F,"> $new_query_file.qual.plot") or die "problems\n";
        print F $res;
        close(F);
    }
    ##WRITE PSEUDOMOLECULE WITHOUT 'N's
    #--------------------------------------
    if ($avoid_Ns ==1)
    {
        print $avoidNFH ">", "ordered_", $id, "without 'N's","\n";
	my $toWrite = write_Fasta ($tmp_nseq);
        print $avoidNFH $toWrite;
    }
    ####################################
    #WRITE CONTIGS WITH NO HIT TO FILE #
    #################################
    my %Cids;
    
    foreach(@Cid)
    {
            chomp;
            $Cids{$_} = 1;
    }
    my @contigs_2bin = ();
    my %h_contigs_2bin;
    
    foreach (@c_keys)
    {
        push(@contigs_2bin, $_) unless exists $Cids{$_};
            
    }
    foreach(@contigs_2bin)
    {
      $h_contigs_2bin{$_}=1;
      
      print $binFH "$_ \n";
            
    }
    $num_inbincontigs= scalar(@contigs_2bin);
    print "#\tBin contigs = $num_inbincontigs\n";
    ########
    # WRITE PSEUDOMOLECULE TO FILE
    #----------------------------------
    my $new_seq = $tmp_seq;
    my $prev_len = length($tmp_seq);
    my $total_len = $prev_len;
    foreach (@contigs_2bin)
    {
        chomp;
        #my $binseq = $contigs_hash{$contigs_2bin[$i]};
        my $l = length ($contigs_hash{$_});
        $total_len +=$l;
    }
    if ($add_bin_2ps ==1) #appending unmapped contigs to pseudomolecule
    {
        
        for (my $i =0; $i < scalar(@contigs_2bin); $i+=1)
        {
            my $binseq = $contigs_hash{$contigs_2bin[$i]};
            $new_seq .=$contigs_hash{$contigs_2bin[$i]};
            my $len_current_contig = length($binseq);
            my $start = $prev_len +1;
            my $end = $start + $len_current_contig -1; 
            my $col = 7;
            if ($start > $total_len)
            {
                    $start = $total_len;
            }
            if ($end >$total_len)
            {
                    $end = $total_len;
            }
            my $co_cord = $start."..".$end;
            my $note = "NO_HIT";
            print $tabFH "FT   contig          ",$co_cord, "\n";
            print $tabFH "FT                   ", "/systematic_id=\"", $contigs_2bin[$i],"\"","\n";
            print $tabFH "FT                   ", "/method=\"", "mummer\"", "\n";
            print $tabFH "FT                   ", "/colour=\"",$col, "\"", "\n";
            print $tabFH "FT                   ", "/", $note, "\n";
            $prev_len= $end;
        }
    }
    my $to_write = write_Fasta ($new_seq);
    print $seqFH $to_write;
    ########
    #WRITE CONTIGS IN BIN TO FILE   #
    #------------------------------------------------------
    if ($fasta_bin ==1)
    {
        foreach(@contigs_2bin)
        {
            print $dbinFH ">", $_, "\n";
            my $to_write = write_Fasta($contigs_hash{$_});
            print $dbinFH $to_write;
        }
    }
    unlink ("$choice.delta");
    unlink ("$choice.filtered.delta");
    unlink ("$choice.cluster");
    unlink ("$choice.tiling");
    #PRINT FINAL MESSAGE        
    print "#\tFINISHED CONTIG ORDERING\n";
    print "#\n#\tTo view your results in ACT\n#\t\t Sequence file 1: $new_reference_file\n#\t\t Comparison file 1: $prefix.crunch\n#\t\t Sequence file 2: $prefix.fasta\n#\n#\t\tACT feature file is: $prefix.tab\n#\t\tContigs bin file is: $prefix.bin\n#\t\tGaps in pseudomolecule are in: $prefix.gaps\n#-------------------------------------------------\n";
    
    #Run tblastx....
    if ($run_blast ==1)
        {
            print "Running tblastx on contigs in bin...\nThis may take several minutes ...\n";
            my $formatdb = 'formatdb -p F -i' ;
#		my @formating = `
            !system("$formatdb $new_reference_file") or die "ERROR: Could not find 'formatdb' for blast\n";
            my $blast_opt = 'blastall  -m 9 -p tblastx -d ';
            my $contigs_inBin = $prefix.'.contigsInbin.fas';
#			my @bigger_b = `
                !system("$blast_opt $new_reference_file -i $contigs_inBin -o blast.out") or die "ERROR: Could not find 'blastall' , please install blast in your working path (other dir==0)\n$blast_opt $new_reference_file -i $contigs_inBin -o blast.out\n \n";
        }
    
    
    if ($pick_primer == 1)
    {
        print " DESIGNING PRIMERS FOR GAP CLOSURE...\n";
        my $qq = "$prefix.fasta";
        pickPrimers($qq, $reference, $flank, $path_toPass, $chk_uniq,$qualAvailable,@Quality_Array);
    } 
}


#------------------------------
sub write_Fasta {
    my $sequence = shift;
    my $fasta_seq ="";
    my $length = length($sequence);
    if ($length <= 60)
    {
      $fasta_seq = $sequence."\n"; 
    }
    elsif ($length> 60 )
    {
        for (my $i =0; $i < $length; $i+=60)
        {
            my $tmp_s = substr $sequence, $i, 60;
            $fasta_seq .= $tmp_s."\n"; 
        }
    } 
    
    return $fasta_seq;
}
#---------------------------------------------- END OF CONTIG ORDERING SUBROUTINES----------------------------------------------------

#----------------------------------------------- PRIMER DESIGN ---------------------------------------------------
sub pickPrimers
{
          #$ps = pseudo molecule,$rf = reference, $flan = flanking region size
          my ($ps,$rf, $flan, $passed_path, $chk_uniq,$qualAvailable, @Quality_Array);
          if (@_==4){
                  ($rf,$ps, $flan, $chk_uniq) = @_;
                   print "Primers without ordering..\n";
                   print $rf;
                   $passed_path = "nucmer";
                   $qualAvailable =0;
                   @Quality_Array = [];
          }
          else #(@_ == 7)
          {
                ($ps,$rf, $flan, $passed_path, $chk_uniq, $qualAvailable, @Quality_Array) = @_;
          }
          
          my $dna='';
          my @gappedSeq;
          my $records='';
          my @sequence;
          my $input='';
	  #tdo
	  my @gappedQual;
	  #my $quality='';
          my $path_toPass = $passed_path;
          my @fasta;
          my $query='';
          my @exc_regions;
          my $ch_name;
          #my $flank = $flan; 
          open (FH, $rf) or die "Could not open reference file\n";
          open (FH2, $ps) or die "Could not open query/pseudomolecule file\n";
          my $ref; #print ".... ", $rf; exit; 
          my @r = <FH>;
          my @qry = <FH2>;
          my $dn = join ("", @qry);
          $ref = join ("", @r);
          $dna = Fasta2ordered ($dn);
          #check if primer3 is installed
          my $pr3 = "primer3_core";
          my ($pr3_path, $pr3_Path, $pr3_path_dir) = checkProg ($pr3);
          #my @check_prog = `which primer3_core`;     
          open (PRI, '>primer3.summary.out') or die "Could not open file for write\n";
          
         # 
          
          #print $ref; exit;
          #PARSING FOR PRIMER3 INPUT
          my ($opt,$min,$max,$optTemp,$minTemp,$maxTemp,$flank,$lowRange,$maxRange,$gcMin,$gcOpt,$gcMax,$gclamp,$exclude,$quality) = getPoptions($qualAvailable); 
          my ($gap_position,@positions, %seq_hash);
          
          my $exc1 = $flank -$exclude;  #start of left exclude
          print "Please wait... extracting target regions ...\n";
          #regular expression extracts dna sequence before and after gaps in sequence (defined by N)
          while($dna=~ /([atgc]{$flank,$flank}N+[atgc]{$flank,$flank})/gi)
          {               
	        $records= $1;
			push (@gappedSeq, $records);
			$gap_position = index($dna, $records);
			push @positions, $gap_position;
			$seq_hash{$gap_position}=$records;
			#dna
			if ($qualAvailable) {
			  my $res;
			  for (my $nn=($gap_position-1); $nn <= ($gap_position-1+length($records)-1); $nn++) {
				$res.="$Quality_Array[$nn] ";
			  }
			  push @gappedQual, $res;			  
			}
          }
        #loop prints out primer targets into a file format accepted by primer3
        my $count=1;
        my $identify='';
        my $seq_num = scalar @gappedSeq;
        my $name= " ";
        
        my ($totalp, @left_name, @right_name, @left_seq, @right_seq);

        my ($leftP_names, $rightP_names, $leftP_seqs, $rightP_seqs, $leftP_start, $leftP_lens, $rightP_ends, $rightP_lens,$left_Exclude,$right_Exclude, $primers_toExc, $prod_size)=
        ("","","","","","","","","","", "", "");    
        
        print $seq_num, " gaps found in target sequence\n"; 
        print "Please wait...\nLooking for primers...\n";
        print "Running Primer3 and checking uniquness of primers...\nCounting left and right primer hits from a nucmer mapping (-c 15 -l 15)\n";
        
        for (my $i=0; $i<$seq_num; $i+=1)
        {            
                    $identify = $count++;
                    if (defined $ch_name)
                    {
                            $name = $ch_name;
                    }
                    my $len = length($gappedSeq[$i]);
                    my $exc2 = $len - $flank;
                    open(FILE, '>data') or die "Could not open file\n";
                    #tdo
                    my $qual='';
                    if ($qualAvailable) {
                      $qual="PRIMER_SEQUENCE_QUALITY=$gappedQual[$i]\nPRIMER_MIN_QUALITY=$quality\n";
                    }
				
#WARNING: indenting the following lines may cause problems in primer3 
print FILE "PRIMER_SEQUENCE_ID=Starting_Pos $positions[$i] 
SEQUENCE=$gappedSeq[$i]
PRIMER_OPT_SIZE=$opt
PRIMER_MIN_SIZE=$min
PRIMER_MAX_SIZE=$max
PRIMER_OPT_TM=$optTemp
PRIMER_MIN_TM=$minTemp
PRIMER_MAX_TM=$maxTemp
PRIMER_NUM_NS_ACCEPTED=1
PRIMER_PRODUCT_SIZE_RANGE=$lowRange-$maxRange
PRIMER_MIN_GC=$gcMin
PRIMER_GC_CLAMP =$gclamp
PRIMER_OPT_GC_PERCENT=$gcOpt
PRIMER_MAX_GC=$gcMax
PRIMER_INTERNAL_OLIGO_EXCLUDED_REGION=$exc1,$exclude $exc2,$exclude
".$qual."Number To Return=1
=\n";
close FILE;

        #runs primer3 from commandline 
        
        ################# NOTE: PRIMER3 SHOULD BE IN YOUR WORKING PATH #########
      
                    my  @Pr3_output = `$pr3_path -format_output <data`;
                    #print $positions[$i], "\t", $i, " ", $path_toPass, "  ", $rf, $exc1, " ",$exc2, "\n";
                    my $fil = join (":%:", @Pr3_output);
                   my ($uniq_primer, $string,$left_nm,$right_nm,$left_sq, $right_sq,$left_strt,$left_ln, $right_End,$right_ln,$primers_toExclude, $product_size)
                    = check_Primers ($fil, $positions[$i], $i,$path_toPass, $rf, $exc1, $exc2);
                    
                    print PRI $string;
                    if ($uniq_primer ==1)
                    {
                              $leftP_names.=$left_nm."\n";
                              $rightP_names.=$right_nm."\n";
                              $leftP_seqs.=$left_sq."\n";
                              $rightP_seqs.=$right_sq."\n";
                              $leftP_start.=$left_strt."\n";
                              $leftP_lens.=$left_ln."\n";
                              $rightP_ends.=$right_End."\n";
                              $rightP_lens.=$right_ln."\n";
                              $left_Exclude.=$exc1."\n";
                              $right_Exclude.=$exc2."\n";
                              $prod_size.=$product_size."\n";
                    }
                    if ($primers_toExclude ne "")
                    {
                              $primers_toExc.= $primers_toExclude; #."\n";
                    }
          
          }
        write_Primers ($leftP_names, $rightP_names, $leftP_seqs, $rightP_seqs, $leftP_start, $leftP_lens, $rightP_ends, $rightP_lens,$primers_toExc,$left_Exclude,$right_Exclude, $prod_size);     
        #write_Primers (@left_name, @right_name, @left_seq, @right_seq,@left_start, @left_len, @right_end, @right_len, @left_exclude, @right_exclude, $primers_toExclude);
        
}

#checks the uniqueness of primers
#input an array with promer3 output for each gap
sub check_Primers
{
          
          my ($fil, $position, $index,$path_toPass, $rf, $exc1, $exc2) = @_;
          my  @Pr3_output = split /:%:/, $fil;           
          my ($left_name, $right_name, $left_seq, $right_seq, $left_start,$left_len,$right_end,$right_len,$left_exclude,$right_exclude) = ("", "", "", "", "", "", "", "", "", "");
          my $primers_toExclude ="";
          my $product_size ="";
          my $string ="";
          my $uniq_primer = 0;
          $string.="=========================================================================================\n";
          $string.="Primer set for region starting at ".$position."\n";
          
          if (defined $Pr3_output[5] && defined $Pr3_output[6])
          {
                    if ($Pr3_output[5]=~ /LEFT PRIMER/)
                    {
                           # print $Pr3_output[5];
                            #check uniquness of primer against the genome
                            my @splits_1 = split (/\s+/, $Pr3_output[5]);
                            my $left_primer = $splits_1[8];
                            my $left_st = $splits_1[2];
                            my $left_length = $splits_1[3];
                            
                            my @splits_2 = split (/\s+/, $Pr3_output[6]);
                            my $right_primer = $splits_2[8];
                            my $right_st = $splits_2[2];
                            my $right_length = $splits_2[3];
                            
                            open (QRY_1, '>./left_query'); # open a file for left primers
                            print QRY_1 ">left_01\n";    #
                            print QRY_1 $left_primer,"\n";
                            open (QRY_2, '>./right_query');
                            print QRY_2 ">right_01\n";
                            print QRY_2 $right_primer,"\n";
                            
                            my ($left_count, $right_count);
                            #if ($chk_uniq eq "nucmer")
                            #{
                                my $options = "-c 15 --coords  -l 15 ";
                                my $rq = "right_query";
                                my $lq = "left_query";
                                my (@right_ps, @left_ps);
                               # print $path_toPass, "\t", $options, "\n";
                                
                        
                                my @Rrun = `$path_toPass $options -p R $rf  $rq &> /dev/null`;
                                print ".";
                                my $f1 = "R.coords";
                                open (RP, $f1) or die "Could not open file $f1 while checking uniqueness of right primer\n";                           
                                  while (<RP>)
                                {
                                    chomp;
                                    if ($_ =~ /right_01$/)
                                    {
                                        push @right_ps, $_;
                                    }
                                }
                                close (RP);
                                my @Lrun = `$path_toPass $options -p L $rf  $lq &> /dev/null`;                               
                                print ".";
                                my $f2 = "L.coords";
                                open (LQ, $f2) or die "Could not open file $f2\n";
                                while (<LQ>)
                                {
                                    chomp;
                                    if ($_ =~ /left_01$/)
                                    {
                                        push @left_ps, $_;
                                    }
                                }
                                close (LQ);
                                $right_count = scalar (@right_ps);  
                                $left_count = scalar(@left_ps); 
                              #check if a primer is not in the excluded region::
                              my $primer_NearEnd =0;
                              if ($left_st > $exc1 || $right_st < $exc2)
                              {
                                        $primer_NearEnd = 1;
                              }
                              
                            if ($left_count < 2 && $right_count<2 && $primer_NearEnd ==0)
                            {
                                    $string.=$left_count."\t".$Pr3_output[5]."\n";
                                    $string.=$right_count."\t".$Pr3_output[6]."\n";
                                    $string.="***************************** PRIMER3 OUTPUT **************************\n";
                                    foreach (@Pr3_output) {$string.=$_;}
                                    
                                    my @prod_size_split = split /\s+/, $Pr3_output[10];
                                    
                                    $product_size = substr($prod_size_split[2], 0, -1);
                                    $left_name = $position;
                                    $right_name = $position;
                                    my $lp_uc = uc ($left_primer);
                                    my $rp_uc = uc($right_primer);
                                        #print $left_count, "..", $right_count, "\t";
                                    $left_seq = $lp_uc;
                                    $right_seq= $rp_uc;
                                    
                                    $left_start= $left_st;
                                    $left_len = $left_length;
                                    
                                    $right_end = $right_st;
                                    $right_len = $right_length;
                                    
                                    $left_exclude = $exc1;
                                    $right_exclude =$exc2;
                                    $uniq_primer =1;
                            }
                            else
                            {
                                        if ($primer_NearEnd ==1)
                                        {
                                             $string.="One of the oligos is near the end of a contig\n";     
                                        }
                                        else
                                        {
                                                  $string.="Primer set not unique\n";
                                        }
                                    $primers_toExclude.=">L.".$position."\n".$left_primer."\n";
                                    $primers_toExclude.=">R.".$position."\n".$right_primer."\n";
                            }
                            
                    }
                    else
                    {
                            $string.="No Primers found\n";
                    }
          }
                    
          return ($uniq_primer, $string,$left_name,$right_name,$left_seq, $right_seq,$left_start,$left_len, $right_end,$right_len,$primers_toExclude, $product_size);
          
          
}

###------------------------------------
# Writes primers and their regions to file
sub  write_Primers {
          my ($leftP_names, $rightP_names, $leftP_seqs, $rightP_seqs, $leftP_start, $leftP_lens, $rightP_ends, $rightP_lens,$primers_toExclude,$left_Exclude,$right_Exclude, $product_sizes) = @_;
          my (@left_name, @right_name, @left_seq, @right_seq, @left_start, @left_len, @right_end, @right_len, @left_exclude, @right_exclude, @product_size);
         
          #open files to read
          @left_name = split /\n/, $leftP_names;
          @right_name= split /\n/, $rightP_names;
          @left_seq = split /\n/, $leftP_seqs;
          @right_seq = split /\n/, $rightP_seqs;
          
          @left_start = split /\n/, $leftP_start;
          @left_len = split /\n/, $leftP_lens;
          @right_end = split/\n/, $rightP_ends;
          @right_len = split /\n/, $rightP_lens;
          @left_exclude = split /\n/, $left_Exclude;
          @right_exclude = split /\n/,$right_Exclude;
          @product_size = split /\n/, $product_sizes;
            
          my $primers_withSize ="";       
          open (SEN, '>sense_primers.out') or die "Could not open file for write\n";
          open (ASEN, '>antiSense_primers.out') or die "Could not open file for write\n";
          open (REG_1, '>sense_regions.out') or die "Could not open file for write\n";
          open (REG_2, '>antiSense_regions.out') or die "Could not open file for write\n";
          
          if ($primers_toExclude ne "")
          {
                    open (PEX, '>primers_toExclude.out') or die "Could not open file for write\n";
                    print PEX $primers_toExclude;
          }
          
          
          my $totalp = scalar (@left_name);
          
          #print $totalp, "\n"; exit;
          
          my $well_pos;
          my $max_plates = ceil($totalp/96);
          #print "MAX Ps ", $max_plates, "\n";
          my $plate=1;
          my $sen ="";
          my $asen ="";
          my $plate_counter =0;
          my $wells = 96;
          for (my $index =0; $index < $totalp; $index += $wells)
          {
                   my $do = $index;
                   my $upper_bound= $index + $wells;
                   if ($upper_bound > $totalp)
                   {
                              $upper_bound = $totalp;
                   }
                   
                   for (my $j=$index; $j <= ($upper_bound-1); $j+=1)
                    {
                       my $i = $j;
                       if ($j < 96)
                       {
                              $well_pos = get_WellPosition ($j);
                       }
                       else
                       {
                            $well_pos = get_WellPosition ($j - $wells)  
                       }
                          
                           #$primers_withSize.=$product_size[$i]."\t"."Plate_".$plate. "\t\tS.".$i."\tS.".$left_name[$i]."\t".
                           print SEN "Plate_".$plate, "\t\t","S.", $i, "\tS.", $left_name[$i], "\t", $left_seq[$i], "\t\t+", "\t", $well_pos, "\n"; 
                           print ASEN "Plate_".$plate, "\t\t","AS.", $i, "\tAS.", $right_name[$i], "\t", $right_seq[$i], "\t\t-","\t", $well_pos,"\n";
                           print REG_1 "Plate_".$plate, "\t\t","S.", $i, "\t", $left_start[$i], "\t", $left_len[$i], "\n";
                           print REG_2 "Plate_".$plate, "\t\t","AS.", $i, "\t", $right_end[$i], "\t",$right_len[$i], "\n";
                       
                    }
                    $plate +=1;
          }
             
        #delete tmp. files
        #my $rm = "rm -f";
        system ("rm -f data left_query right_query R.delta R.cluster R.coords L.delta L.cluster L.coords");
        print "\nPRIMER DESIGN DONE\n\n";
	# end of primer design program
}#//
#####
# returns a well position for oligos 
sub get_WellPosition{
          
          my $j = shift;
          my $well_pos;
          if ($j < 12)
          {
                    $well_pos = "a".($j+1);
          }
          elsif ($j>11 && $j<24) {
                    $well_pos = "b". (($j+1) -12);
          }
          elsif ($j>23 && $j<36) {
                    $well_pos = "c". (($j+1) -24);
          }
          elsif ($j>35 && $j<48) {
                    $well_pos = "d". (($j+1) - 36);
          }
          elsif($j>47 && $j<60) {
                    $well_pos = "e". (($j+1) -48);
          }
          elsif ($j>59 && $j<72)
          {
                    $well_pos = "f". (($j+1) - 60);
          }
          elsif ($j>71 && $j< 84)
          {
                    $well_pos = "g". (($j+1) - 72);
          }
          elsif ($j>83 && $j<96)
          {
                    $well_pos = "h". (($j+1) - 84);
          }
          return $well_pos;
}


####################################################################
#get options for primer design
#----------------------
sub getPoptions{
          
          my $qualAvailable = shift;
          #### USER INPUTS ##########
        #ask for optimum primer size
        print "\nEnter Optimum Primer size (default 20 bases):";
        my $opt=<STDIN>;
        chomp $opt;
        if($opt eq '')
        {
                $opt = 20;
        }
        #ask for minimum primer size
        print "\nEnter Minimum Primer size (default 18 bases):";
        my $min=<STDIN>;
        chomp $min;
        if($min eq '')
        {
                $min = 18;
        }
        #ask for maximum primer size
        print "\nEnter Maximum Primer size (default 27 bases):";
        my $max= <STDIN>;
        chomp $max;
        if($max eq '')
        {
                $max= 27;
        }
        #ask for optimum primer temperature
        print "\nEnter Optimum melting temperature (Celcius) for a primer oligo (default 60.0C):";
        my $optTemp=<STDIN>;
        chomp $optTemp;
        if($optTemp eq '')
        {
                $optTemp = 60.0;
        }
        #ask for minimum primer temperature
        print "\nEnter Minimum melting temperature (Celcius) for a primer oligo (default 57.0C):";
        my $minTemp=<STDIN>;
        chomp $minTemp;
        if($minTemp eq '')
        {
                $minTemp = 57.0;
        }
        #ask for maximum primer temperature
        print "\nEnter Maximum melting temperature (Celcius) for a primer oligo (default 63.0C):";
        my $maxTemp=<STDIN>;
        chomp $maxTemp;
        if($maxTemp eq '')
        {
                $maxTemp = 63.0;
        }
        print "\nEnter flanking region size (default 1000 bases): ";
        my $flank=<STDIN>;
        chomp $flank;
        if ($flank eq '')
        {
          $flank = 1000;
        }
        #ask for primer product range
        print "\nEnter minimum product size produced by primers (default =flanking size):";
        my $lowRange=<STDIN>;
        chomp $lowRange;
        if($lowRange eq '')
        {
                $lowRange = $flank;
        }
        print "\nEnter maxmimum product size produced by primers (default 7000):";
        my $maxRange=<STDIN>;
        chomp $maxRange;
        if($maxRange eq '')
        {
                $maxRange = 7000;
        }
        #ask for minimum GC content in primers
        print "\nEnter minimum GC content in primers (default 20%):";
        my $gcMin=<STDIN>;
        chomp $gcMin;
        if($gcMin eq '')
        {
                $gcMin = 20.0;
        }
        #ask for optimum GC content in primers
        print "\nEnter optimum GC content in primers (default 50%):";
        my $gcOpt=<STDIN>;
        chomp $gcOpt;
        if($gcOpt eq '')
        {
                $gcOpt = 50.0;
        }
        #ask for maximum GC content in primers
        print "\nEnter maximum GC content in primers (default 80%):";
        my $gcMax=<STDIN>;
        chomp $gcMax;
        if($gcMax eq '')
        {
                $gcMax = 80.0;
        }
        print "\nEnter GC clamp  (default 1):";
        my $gclamp=<STDIN>;
        chomp $gclamp;
        if($gclamp eq '')
        {
                $gclamp = 1;
        }
	print "\nEnter size of region to exclude at the end of contigs (default 100 bases):";
	my $exclude=<STDIN>;
	chomp $exclude;
	if ($exclude eq '')
	{
		$exclude = 100;
	}


	  #tdo
          my $quality='';
	  if ($qualAvailable)
          {
		
                    print "\nEnter minimum quality for primer pick (default 40):";
                    $quality=<STDIN>;
                    chomp $quality;
                    if($quality eq '')
		  {
			$quality = 40;
		  }
	  }

          
return ($opt,$min,$max,$optTemp,$minTemp,$maxTemp,$flank,$lowRange,$maxRange,$gcMin,$gcOpt,$gcMax,$gclamp,$exclude, $quality);
          
}
###############
#-----------------------------------------------------END of PRIMER DESIGN ----------------------------------------------------------------
#-----------------------------------------------------END OF ABACAS -----------------------------------------------------------------------


