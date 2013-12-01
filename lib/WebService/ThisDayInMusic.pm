package WebService::ThisDayInMusic;

use Moose;
use MooseX::Privacy;
use LWP::UserAgent;
use DateTime;
use JSON qw(decode_json);
use Carp;

use Data::Dumper;

use namespace::autoclean;

has 'base_url' => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [qw/Private/],
    required => 1,
    default  => 'http://icdif.com/thisdayinmusic/events/'
);

has 'date' => (
    is      => 'ro',
    isa     => 'DateTime',
    traits  => [qw/Private/],
    default => sub { return DateTime->now() },
);

has 'filters' => (
    traits  => ['Array'],
    is      => 'ro',
    default => sub { return [] },
    handles => { add_filters => 'push', }
);

#gets the full url
sub url {
    my $self = shift;

    my $url = $self->base_url;

    #add filters to the url
    my @filters = @{ $self->filters };
    if ( scalar @filters ) {
        for my $filter (@filters) {
            $filter = sprintf( 'filters[]=%s', $filter );
        }

        $url = sprintf( '%s?%s', $url, join( '&', @filters ) );
    }

    return $url;
}

sub get {
    my $self  = shift;
    my %arg   = @_;
    my $day   = $arg{'day'};
    my $month = $arg{'month'};

    my $url = $self->url;
    if ( defined $day && defined $month ) {
        $url = sprintf( '%s&day=%s&month=%s', $url, $day, $month );
    }

    #get the results from server
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;

    my $response = $ua->get($url);

    my $events = [];

    if ( $response->is_success ) {
        my $response = $response->decoded_content;
        $events = decode_json $response;
    }
    else {
        Carp::carp $response->status_line;
    }

    return $events;
}

no Moose;
__PACKAGE__->meta->make_immutable;
