package APlaylistADay::Playlist;

use DateTime;
use Mojo::Base 'Mojolicious::Controller';
use Moose;
use MooseX::Privacy;
use WebService::ThisDayInMusic;
use WebService::Google::Freebase;
use Redis;

use APlaylistADay::Event;

use Data::Dumper;

has 'events' => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[APlaylistADay::Event]',
    default => sub { return [] },
    handles => { add_event => 'push', }
);

has 'date' => (
    is      => 'rw',
    isa     => 'DateTime',
    default => sub { return DateTime->now() },
);

sub get {
    my $self = shift;

    #TODO: check validity of day and month, and set property of current class
    my ( $day, $month, $page ) = (
        $self->stash('day'), $self->stash('month'), $self->stash('page') || 0
    );

    my $date = DateTime->now();
    if ( $month && $day ) {
        $date = DateTime->new(
            'year'  => $date->year(),
            'month' => $month,
            'day'   => $day
        );
    }
    $self->date($date);

    my $use_cache = $self->app->{config}->{'use_cache'};

    my $redis = $use_cache ? $self->get_redis() : undef;

    #finds playlist for this day on cache
    my $results
        = $redis
        ? $redis->get( sprintf( '%s-%s', $page, $date->ymd ) )
        : undef;
    $results = JSON::decode_json $results
        if $results;

    #if none on cache, find it and set it on cache
    if ( !$results || !scalar @{ $results || [] } ) {
        $results = $self->find_playlist($page);

        $redis->set( sprintf( '%s-%s', $page, $date->ymd ),
            JSON::encode_json($results) )
            if $use_cache;
    }

    #respond to several content-types
    $self->respond_to(
        json => { json => $results },
        html => sub {
            $self->render(
                'results' => $results,
                'page'    => $page,
                'date'    => $self->date->strftime('%B, %e')
            );
        },
        any => { text => '', status => 204 }
    );
}

#instantiates redis from config url or from environment variable
private_method get_redis => sub {
    my $self = shift;

    my %redis_arg;
    if ( $ENV{'REDISTOGO_URL'} ) {
        my ( $password, $server )
            = $ENV{'REDISTOGO_URL'} =~ m/^redis\:\/\/redistogo:(.*)@(.*)\/$/;

        %redis_arg = (
            'server'   => $server,
            'password' => $password,
        );
    }
    else {
        $redis_arg{'server'} = $self->app->{config}->{'redis'}->{'url'};
    }

    print STDERR 'server: ', $redis_arg{'server'}, "\n", 'password: ',
        $redis_arg{'password'};

    my $redis = Redis->new(%redis_arg);

    return $redis;
};

private_method find_events => sub {
    my $self = shift;

    my ( $day, $month ) = ( $self->date->day, $self->date->month_name );

    print STDERR $day, $month, "\n";

    my $dayinmusic = WebService::ThisDayInMusic->new();

    #limit to events of these types
    $dayinmusic->add_filters( 'Birth', 'Death' );
    my $events = $dayinmusic->get( 'day' => $day, 'month' => $month );

    return $events;
};

private_method find_playlist => sub {
    my ( $self, $page ) = @_;

    my $events = $self->find_events();

    #splice list according to pagination values
    #TODO: how to avoid tracks without video
    my @list = splice @{ $events || [] },
        $page * $self->app->{config}->{'playlist'}->{'pagesize'},
        $self->app->{config}->{'playlist'}->{'pagesize'};

    my @results;
    for my $element (@list) {
        my %param = (
            'type'        => $element->{'type'},
            'date'        => $element->{'date'},
            'description' => $element->{'description'},
        );
        $param{'artist_name'} = $element->{'name'}
            if $element->{'name'};

        my $event = APlaylistADay::Event->new(%param);

        #find artist represented in the event
        my $artist
            = $event->find_event_artist(
            $self->app->{config}->{'echonest'}->{'key'} )
            || next;

        #creates a structure to be used in rendering
        my $attr = {
            'date'        => $event->date,
            'name'        => $artist->name,
            'description' => $event->description,
            'type'        => $event->type,
        };

        #finds a track/video for the artist found
        my $video = $artist->find_track(
            $self->app->{config}->{'google'}->{'key'} );

        $attr->{'video'} = $video
            if $video;

        $self->add_event($event);

        push @results, $attr;
    }

    return \@results;
};

1;
