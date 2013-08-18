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

    my $count = 0;
    for my $event ( @{ $events || [] } ) {

        #TODO: replace this with pagination
        last
            if $count == $self->app->{config}->{'playlist'}->{'max'};

        my $artist = $self->_find_event_artist($event);
        next unless ref $artist eq 'HASH';

        my $key = $artist->{'id'} ? $artist->{'id'} : $artist->{'name'};

        #save the number of times the same artist has already been found
        $artists{$key}++;
        $event->{'artist'} = $artist;

      #        my $video = $self->_find_artist_video( $artist, $artists{$key},
      #            $artist->{'id'} ? 0 : 1 );

        my $video
            = $self->_find_artist_video( $artist->{'name'}, $artists{$key} );

        $event->{'video'} = $video
            if defined $video && ref $video eq 'HASH';

        $count++;
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

    #if one has the name of the artist, there's no need to use the API
    return { 'name' => $event->{'name'} }
        if $event->{'name'};

    my $text = $event->{'description'};

    #find artists in string, ordered by hottness
    my $url = sprintf(
        "%s?api_key=%s&format=json&results=1&sort=hotttnesss-desc&text=%s",
        $self->app->{config}->{'echonest'}->{'extract'},
        $self->app->{config}->{'echonest'}->{'key'}, $text,
    );

    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($url);
    my $result = $json->res->json;

    #no error in call
    if ( $result->{'response'}->{'status'}->{'code'} == 0 ) {
        my $artist = shift $result->{'response'}->{'artists'};

        return $artist;
    }
    else {
        my $log = Mojo::Log->new;
        $log->error( 'Error connecting to echonest: '
                . $result->{'response'}->{'status'}->{'message'} );
    }

    return;
}

sub _find_artist_video {
    my $self   = shift;
    my $artist = shift;
    my $start  = shift;

    #in order to avoid the same video for the artist in the events list
    $start = defined $start ? $start : 0;

    #find topic related to artist
    my $url = sprintf( "%s?query=%s&indent=true&lang=en",
        $self->app->{config}->{'google'}->{'freebase'}->{'search'}, $artist,
    );

    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($url);
    my $result = $json->res->json;

    return
        unless $result->{'hits'};

    my @results = @{ $result->{'result'} || [] };

    my $result;
    while ( scalar @results ) {
        $result = shift @results;

        #only topics related to music are accepted
        last
            if $result->{'notable'}->{'name'} =~ /artist|musical group/i;
    }

    return
        unless ref $result eq 'HASH' && $result->{'mid'};

#find video of topic
#TODO: add some sort of randomness to avoid the same video appearing always for the same artist
    $url = sprintf(
        "%s?key=%s&part=snippet&topicId=%s&type=video",
        $self->app->{config}->{'google'}->{'youtube'}->{'search'},
        $self->app->{config}->{'google'}->{'key'},
        $result->{'mid'},
    );

    $ua     = Mojo::UserAgent->new;
    $json   = $ua->get($url);
    $result = $json->res->json;

    return unless scalar @{ $result->{'items'} };

    my @items = @{ $result->{'items'} || [] };

    my $item = shift @items;

#avoid repetition of videos when the same artist appears several times in the event list
    if ( $start && $items[$start] ) {
        $item = $items[$start];
    }

    my $id = $item->{'id'}->{'videoId'};
    return {
        'id'          => $id,
        'title'       => $item->{'snippet'}->{'title'},
        'description' => $item->{'snippet'}->{'description'},
    };
}

#find video for an artist using echonest api
sub _find_artist_video_old {
    my $self     = shift;
    my $artist   = shift;
    my $start    = shift;
    my $use_name = shift || 0;

    my $key   = 'id';
    my $value = $artist->{'id'};
    if ($use_name) {
        $key   = 'name';
        $value = $artist->{'name'};
    }

    #in order to avoid the same video for the artist in the events list
    $start = defined $start ? $start : 0;

    # most recent videos found on the web related to the artist
    my $url = sprintf(
        "%s?api_key=%s&format=json&start=%s&%s=%s&results=1",
        $self->app->{config}->{'echonest'}->{'video'},
        $self->app->{config}->{'echonest'}->{'key'},
        $start, $key, $value,
    );

    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($url);
    my $result = $json->res->json;

    if ( $result->{'response'}->{'status'}->{'code'} == 0 ) {
        my $video = shift $result->{'response'}->{'video'}
            || return;

        if ( $video->{'url'} =~ m/v\=(\w+)\&/ ) {
            $video->{'id'} = $1;
            return $video;
        }
    }
    else {
        my $log = Mojo::Log->new;
        $log->error( 'Error connecting to echonest: '
                . $result->{'response'}->{'status'}->{'message'} );
    }
    return;
}

1;
