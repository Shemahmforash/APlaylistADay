package APlaylistADay::Playlist;

use DateTime;
use Mojo::Base 'Mojolicious::Controller';
use Moose;
use MooseX::Privacy;
use WebService::ThisDayInMusic;
use WebService::Google::Freebase;

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

    print STDERR $day, $month, "\n";

    my $dayinmusic = WebService::ThisDayInMusic->new();

    #limit to events of these types
    $dayinmusic->add_filters( 'Birth', 'Death' );
    my $events = $dayinmusic->get( 'day' => $day, 'month' => $month );

    return $events;
};

1;
