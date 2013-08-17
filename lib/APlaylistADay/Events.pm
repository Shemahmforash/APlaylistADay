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
    my @results;
    for my $event ( @{ $events || [] } ) {
        my $artist = $self->_find_event_artist($event);
        next unless $artist;

        $event->{'artist'} = $artist;

        my $video = $self->_find_artist_video( $artist->{'name'} );
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

    my $url = sprintf(
        "%s?api_key=%s&format=json&results=1&text=%s",
        $self->app->{config}->{'echonest'}->{'extract'},
        $self->app->{config}->{'echonest'}->{'key'},
        $event->{'description'},
    );

    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($url);
    my $result = $json->res->json;

    #no error in call
    if ( $result->{'response'}->{'status'}->{'code'} == 0 ) {
        my $artist = pop $result->{'response'}->{'artists'};

        return $artist;
    }

    return;
}

#find youtube video for an artist
sub _find_artist_video {
    my $self   = shift;
    my $artist = shift;

    my $url = sprintf(
        '%s?part=snippet&maxResults=1&order=relevance&q=%s&type=video&videoCaption=any&videoSyndicated=true&key=%s',
        $self->app->{'config'}->{'youtube'}->{'search'},
        $artist, $self->app->{'config'}->{'youtube'}->{'key'}
    );

    my $ua   = Mojo::UserAgent->new;
    my $json = $ua->get($url);

    my $results = $json->res->json;

    if ( my $items = $results->{'items'} ) {
        #use the first result returned
        my $item = shift @{$items};

        my $id = $item->{'id'}->{'videoId'};
        return {
            'id'          => $id,
            'title'       => $item->{'snippet'}->{'title'},
            'description' => $item->{'snippet'}->{'description'},
        };
    }

    return;
}

1;
