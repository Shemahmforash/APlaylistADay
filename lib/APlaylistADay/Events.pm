package APlaylistADay::Events;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::UserAgent;

use Data::Dumper;

sub get {
    my $self = shift;

    my ( $day, $month ) = ( $self->stash('day'), $self->stash('month') );

    # Fresh user agent
    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get( $self->app->{config}->{'events'}->{'url'} );
    my $events = $json->res->json;

    #for each event, try to find an artist using echonest
    my $base = sprintf(
        "%s?api_key=%s&format=json&results=1",
        $self->app->{config}->{'echonest'}->{'extract'},
        $self->app->{config}->{'echonest'}->{'key'}
    );

    my @results;
    for my $event ( @{ $events || [] } ) {
        my $url = sprintf( '%s&text=%s', $base, $event->{'description'} );

        $json = $ua->get($url);
        my $result = $json->res->json;

        #no error in call
        if ( $result->{'response'}->{'status'}->{'code'} == 0 ) {
            my $artist = pop $result->{'response'}->{'artists'};

            $event->{'artist'} = $artist;

            my $video = $self->_find_artist_video( $artist->{'name'} );
            $event->{'video'} = $video
                if defined $video && ref $video eq 'HASH';
        }

        push @results, $event;
    }

    $self->render( 'results' => \@results );
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
        my $item = shift @{$items};

        my $id = $item->{'id'}->{'videoId'};
        return {
            'id'          => $id,
            'title'       => $item->{'snippet'}->{'title'},
            'description' => $item->{'snippet'}->{'description'},
            'url' => sprintf( 'http://www.youtube.com/watch?v=%s', $id ),
        };
    }

    return;
}

1;
