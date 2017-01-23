package Bio::AssemblyImprovement::IvaQC::Main;

# ABSTRACT: Wrapper around iva_qc 

# =head1 SYNOPSIS

# =cut

use File::Spec;
use Moose;
use Cwd;
use File::Path qw( rmtree );


has 'db'               => ( is => 'ro', isa => 'Str', required => 0, default => "/lustre/scratch118/infgen/pathogen/pathpipe/kraken/assemblyqc_fluhiv_20150728" );
has 'forward_reads'    => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'reverse_reads'    => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'assembly'         => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'prefix'		   => ( is => 'ro', isa => 'Str', required => 0, default => "iva_qc");
has 'iva_qc_exec'	   => ( is => 'ro', isa => 'Str', required => 0, default => "/software/pathogen/external/bin/iva_qc");
has 'working_directory'=> ( is => 'ro', isa => 'Str', required => 0, default => getcwd());



sub run {
    my ($self) = @_;

    # remember cwd and cd into working directory
    my $cwd = getcwd();
    my $iva_qc_dir = $self->working_directory."/iva_qc";
    if (! -d $iva_qc_dir) {
		mkdir $iva_qc_dir;
    } 
    chdir( $iva_qc_dir );
    
    my $cmd = join(
        ' ',
        (
            $self->iva_qc_exec,
            '-f', $self->forward_reads,
            '-r', $self->reverse_reads,
            '--ref_db', $self->db,
            $self->assembly,
            $self->prefix,
        )
    );
	
    system("$cmd 2>/dev/null") and warn "Error running iva_qc with: $cmd \n"; 

	# delete files and directories that were considered unnecessary
	unlink($self->prefix.'.contig_placement.R',
		   $self->prefix.'.reads_mapped_to_assembly.bam',
		   $self->prefix.'.reads_mapped_to_assembly.bam.bai',
		   $self->prefix.'.reads_mapped_to_assembly.bam.flagstat',
		   $self->prefix.'.reads_mapped_to_ref.bam',
		   $self->prefix.'.reads_mapped_to_ref.bam.bai',
		   $self->prefix.'.reads_mapped_to_ref.bam.flagstat',    
	);
	rmtree($self->prefix.'.gage');

    #change back to cwd
    chdir ($cwd);

    
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Bio::AssemblyImprovement::IvaQC::Main - Wrapper around iva_qc 

=head1 VERSION

version 1.151770

=head1 AUTHOR

Andrew J. Page <ap13@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut

