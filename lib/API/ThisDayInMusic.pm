package API::ThisDayInMusic;

use Moose;
use MooseX::Privacy;
use LWP::UserAgent;
use JSON qw(decode_json);

use Data::Dumper;

use namespace::autoclean;

has 'url' => (
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

#TODO: add filters

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
        my $response = $response->decoded_content;    # or whatever
        $events = decode_json $response;
    }
    else {
        carp $response->status_line;
    }

    return $events;
}

no Moose;
__PACKAGE__->meta->make_immutable;
