package APlaylistADay::Events;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::UserAgent;

use Data::Dumper;

sub get {
    my $self = shift;

    my $event_url = $self->app->{config}->{'events'}->{'url'};

    my ( $day, $month ) = ( $self->stash('day'), $self->stash('month') );
    if ( defined $day && defined $month ) {
        $event_url
            = sprintf( '%s?day=%s&month=%s', $event_url, $day, $month );
    }

    # Fresh user agent
    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($event_url);
    my $events = $json->res->json;

    #for each event, try to find an artist using echonest
    my %artists;
    my @results;
    for my $event ( @{ $events || [] } ) {
        my $artist = $self->_find_event_artist($event);
        next unless ref $artist eq 'HASH' && $artist->{'id'};

        my $id = $artist->{'id'};

#save the number of times the same artist has already been found in the events list
        $event->{'artist'} = $artist;
        $artists{$id}++;

        my $video = $self->_find_artist_video( $id, $artists{$id} );
        $event->{'video'} = $video
            if defined $video && ref $video eq 'HASH';

        push @results, $event;
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

#find most probable artist names in a string
sub _find_event_artist {
    my $self  = shift;
    my $event = shift;

    #find artists in string, ordered by hottness
    my $url = sprintf(
        "%s?api_key=%s&format=json&results=1&sort=hotttnesss-desc&text=%s",
        $self->app->{config}->{'echonest'}->{'extract'},
        $self->app->{config}->{'echonest'}->{'key'},
        $event->{'description'},
    );

    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($url);
    my $result = $json->res->json;

    #no error in call
    if ( $result->{'response'}->{'status'}->{'code'} == 0 ) {
        my $artist = shift $result->{'response'}->{'artists'};

        return $artist;
    }

    return;
}

#find video for an artist using echonest api
sub _find_artist_video {
    my $self   = shift;
    my $artist = shift;
    my $start  = shift;

    #in order to avoid the same video for the artist in the events list
    $start = defined $start ? $start : 0;

    # most recent videos found on the web related to the artist
    my $url = sprintf(
        "%s?api_key=%s&format=json&start=%s&id=%s&results=1",
        $self->app->{config}->{'echonest'}->{'video'},
        $self->app->{config}->{'echonest'}->{'key'},
        $start, $artist,
    );

    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($url);
    my $result = $json->res->json;

    if ( $result->{'response'}->{'status'}->{'code'} == 0 ) {
        my $video = shift $result->{'response'}->{'video'};

        if ( $video->{'url'} =~ m/v\=(\w+)\&/ ) {
            $video->{'id'} = $1;
            return $video;
        }
    }
    return;
}

1;
