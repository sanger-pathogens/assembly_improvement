package Bio::AssemblyImprovement::IvaQC::Main;

# ABSTRACT: Wrapper around iva_qc 

# =head1 SYNOPSIS

# =cut

use File::Spec;
use Moose;
use Cwd;
use File::Path qw( rmtree );


has 'db'               => ( is => 'ro', isa => 'Str', required => 0, default => "default/kraken/db" );
has 'forward_reads'    => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'reverse_reads'    => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'assembly'         => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'prefix'		   => ( is => 'ro', isa => 'Str', required => 0, default => "iva_qc");
has 'iva_qc_exec'	   => ( is => 'ro', isa => 'Str', required => 0, default => "iva_qc");
has 'working_directory'=> ( is => 'ro', isa => 'Str', required => 0, default => getcwd());



sub run {
    my ($self) = @_;

    # remember cwd and cd into working directory
    my $cwd = getcwd();
    my $iva_qc_dir = $self->working_directory."/iva_qc";
    if (! -d $iva_qc_dir) {
		mkdir $iva_qc_dir or die "Could not create $iva_qc_dir";
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
	# run command
    if (system($cmd)) {
        die "Error running iva_qc with:\n$cmd";
    }
    # delete files and directories that were considered unnecessary
    unlink('out.contig_placement.R',
           'out.reads_mapped_to_assembly.bam',
           'out.reads_mapped_to_assembly.bam.bai',
           'out.reads_mapped_to_assembly.bam.flagstat',
           'out.reads_mapped_to_ref.bam',
           'out.reads_mapped_to_ref.bam.flagstat',    
    );
    rmtree('out.gage');
    
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

