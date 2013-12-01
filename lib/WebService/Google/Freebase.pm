package WebService::Google::Freebase;

use Moose;
use MooseX::Privacy;
use LWP::UserAgent;
use JSON qw(decode_json);

use Data::Dumper;

use namespace::autoclean;

has 'base_url' => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [qw/Private/],
    required => 1,
    default  => 'https://www.googleapis.com/freebase/v1/search'
);

#make this class more general
sub get {
    my $self = shift;

    my %arg = @_;

    return unless $arg{'query'};

    my @args = map { sprintf( '%s=%s', $_, $arg{$_} ) } keys %arg;

    my $url = sprintf( '%s?%s', $self->base_url, join( '&', @args ) );

    #get the results from server
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;

    my $response = $ua->get($url);

    my $result;
    if ( $response->is_success ) {
        my $response = $response->decoded_content;
        $result = decode_json $response;
    }
    else {
        print STDERR Dumper $response->status_line;
#        carp $response->status_line;
    }


    print STDERR "freebase topics:";
    print STDERR Dumper $result;
   
    return
        unless $result && $result->{'hits'};

    my @results = @{ $result->{'result'} || [] };


    return \@results;
}

no Moose;
__PACKAGE__->meta->make_immutable;
