package Bio::AssemblyImprovement::IvaQC::Main;

# ABSTRACT: Wrapper around iva_qc 

# =head1 SYNOPSIS

# =cut

use File::Spec;
use Moose;


has 'db'               => ( is => 'ro', isa => 'Str', required => 0, default => "default/kraken/db" );
has 'forward_reads'    => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'reverse_reads'    => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'assembly'         => ( is => 'ro', isa => 'Str', required => 1 ); 
has 'prefix'		   => ( is => 'ro', isa => 'Str', required => 0, default => "iva_qc_");
has 'iva_qc_exec'	   => ( is => 'ro', isa => 'Str', required => 0, default => "iva_qc");



sub run {
    my ($self) = @_;
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

    if (system($cmd)) {
        die "Error running iva_qc with:\n$cmd";
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

