package Bio::AssemblyImprovement::Util::GetReadLengthsRole;
# ABSTRACT: Role for getting the read lengths from a fastq file (useful when reads are of varying lengths)

=head1 SYNOPSIS

Reads in fastq file

=cut

use Moose::Role;
use Bio::SeqIO;


sub _get_read_names_and_lengths {
  
    my ( $self, $input_filename) = @_;
	return undef unless(defined($input_filename));
	
	my %read_names_with_length;
	
    if ( $input_filename =~ /\.fq$/ || $input_filename =~ /\.fastq$/  ) {
    	my $fastq_obj =  Bio::SeqIO->new( -file => $input_filename , -format => 'Fastq');
      	while(my $seq = $fastq_obj->next_seq()){    	
      		# Add the read name and the read length to the hash
      		$read_names_with_length{ $seq->id() } = length( $seq->seq() ); 
      	}
      	
      	return \%read_names_with_length;
    }
    else {
        return undef; # Error message?
    }
}

sub _get_read_lengths {
  
    my ( $self, $input_filename) = @_;
	return undef unless(defined($input_filename));
	
	my @read_lengths;
	
    if ( $input_filename =~ /\.fq$/ || $input_filename =~ /\.fastq$/  ) {
    	my $fastq_obj =  Bio::SeqIO->new( -file => $input_filename , -format => 'Fastq');
      	while(my $seq = $fastq_obj->next_seq()){    	
      		# Add the read lengths to an array
      		push( @read_lengths, length($seq->seq()) ); 
      	}
      	return \@read_lengths;
    }
    else {
        return undef; # Error message?
    }
}

no Moose;
1;

