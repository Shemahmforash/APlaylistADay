package WebService::Google::Youtube;

use Moose;
use MooseX::Privacy;
use LWP::UserAgent;
use JSON qw(decode_json);
use Carp;

use Data::Dumper;

use namespace::autoclean;

has 'base_url' => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [qw/Private/],
    required => 1,
    default  => 'https://www.googleapis.com/youtube/v3/search'
);

has 'key' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

#todo: generalize this and make youtube and freebase use the same class as basis
sub get {
    my $self = shift;

    my %arg = @_;

    my @args = map { sprintf( '%s=%s', $_, $arg{$_} ) } keys %arg;
    unshift @args, 'key=' . $self->key;

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
    }

    print STDERR "youtube videos:";
    print STDERR Dumper $result;

    return $result;
}


no Moose;
__PACKAGE__->meta->make_immutable;
