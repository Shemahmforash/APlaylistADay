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
    default  => 'http://thisdayinmusic.icdif.com/api/v0.1/'
);

has 'date' => (
    is      => 'ro',
    isa     => 'DateTime',
    traits  => [qw/Private/],
    default => sub { return DateTime->now() },
);

has 'results' => (
    'is' => 'rw',
    'isa' => 'Int',
    'default' => 0,
);

has 'offset' => (
    'is' => 'rw',
    'isa' => 'Int',
    'default' => 0,
);

has 'fields' => (
    traits  => ['Array'],
    is      => 'ro',
    default => sub { return [] },
    handles => { add_field => 'push', }
);


#gets the full url
sub url {
    my $self = shift;
    my ( $action, $day, $month ) = @_;

    my $url = $self->base_url . $action . '/';

    my $query;

    #add date to the query string
    if ( defined $day && defined $month ) {
        $query = sprintf( '%s&day=%02d&month=%02d', $query, $day, $month );
    }

    $query .= sprintf( '&offset=%d', $self->offset )
        if $self->offset; 

    $query .= sprintf( '&results=%d', $self->results )
        if $self->results; 

    for my $field ( @{ $self->fields } ) {
        $query .= "&fields[]=$field";
    }

    $url = sprintf( '%s?%s', $url, $query )
        if $query;

    return $url;
}

sub get {
    my $self   = shift;
    my %arg    = @_;
    my $action = $arg{'action'};
    my $day    = $arg{'day'};
    my $month  = $arg{'month'};
    my $fields = $arg{'fields'};

    $self->offset( $arg{'offset'} )
        if( defined $arg{'offset'} );

    $self->results( $arg{'results'} )
        if( $arg{'results'} );

    if( $fields && ref $fields eq 'ARRAY' ) {
        for my $field ( @{ $fields || [] } ) {
            $self->add_field( $field );
        }
    }

    die "Undefined action"
        unless $action;

    my $url = $self->url( $action, $day, $month );
    print STDERR $url, "\n";

    #get the results from server
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;

    print STDERR $ua->timeout(), "\n";

    my $response = $ua->get($url);

    print STDERR "Response: ";
    print STDERR Dumper $response;

    my $events = [];

    if ( $response->is_success ) {
        my $response = $response->decoded_content;
        $events = decode_json $response;

        print STDERR "Events: ";
        print STDERR Dumper $events;

    }
    else {
        print STDERR $response->status_line;
    }

    return $events;
}

no Moose;
__PACKAGE__->meta->make_immutable;
