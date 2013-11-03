package APlaylistADay::Playlist;

use DateTime;
use Mojo::Base 'Mojolicious::Controller';
use Moose;
use MooseX::Privacy;

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
    is      => 'ro',
    isa     => 'DateTime',
    default => sub { return DateTime->now() },
);

sub get {
    my $self = shift;

    #TODO: check validity of day and month, and set property of current class
    my ( $day, $month, $page ) = (
        $self->stash('day'), $self->stash('month'), $self->stash('page') || 0
    );

    my $events = $self->find_events( 'day' => $day, 'month' => $month );

    #splice list according to pagination values
    my @list = splice @{ $events || [] },
        $page * $self->app->{config}->{'playlist'}->{'pagesize'},
        $self->app->{config}->{'playlist'}->{'pagesize'};

    my @results;
    for my $element (@list) {
        my $description = $element->{'description'};

        my %param = (
            'type'             => $element->{'type'},
            'date'             => $element->{'date'},
            'description'      => $description,
            'echonest_api_key' => $self->app->{config}->{'echonest'}->{'key'},
            'echonest_extract' =>
                $self->app->{config}->{'echonest'}->{'extract'},
            'google_api_key' => $self->app->{config}->{'google'}->{'key'},
            'youtube_search_url' =>
                $self->app->{config}->{'google'}->{'youtube'}->{'search'},
            'freebase_google_search_url' =>
                $self->app->{config}->{'google'}->{'freebase'}->{'search'},
        );

        $param{'artist'} = $element->{'name'}
            if $element->{'name'};

        my $event = APlaylistADay::Event->new(%param);

        $self->add_event($event);

        my $attr = {
            'date'        => $event->date,
            'name'        => $event->artist,
            'description' => $event->description,
            'type'        => $event->type,
        };
        $attr->{'video'} = $event->track->id
            if $event->track;

        push @results, $attr;
    }

    #respond to several content-types
    $self->respond_to(
        json => { json => \@results },
        html => sub {
            $self->render( 'results' => \@results );
        },
        any => { text => '', status => 204 }
    );

}

private_method find_events => sub {
    my $self = shift;
    my %arg  = @_;

    my $day   = $arg{'day'};
    my $month = $arg{'month'};

    my $event_url = sprintf( '%s?filters[]=Birth&filters[]=Death',
        $self->app->{config}->{'events'}->{'url'} );

    if ( defined $day && defined $month ) {
        $self->date( DateTime->new( 'day' => $day, 'month' => $month ) );
        $event_url
            = sprintf( '%s&day=%s&month=%s', $event_url, $day, $month );
    }

    # Fresh user agent
    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($event_url);
    my $events = $json->res->json;

    return $events;
};

1;
