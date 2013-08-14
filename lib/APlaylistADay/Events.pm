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
    my @artists;
    for my $event ( @{ $events || [] } ) {
        my $url = sprintf( '%s&text=%s', $base, $event->{'description'} );

        $json = $ua->get($url);
        my $result = $json->res->json;

        #no error in call
        if ( $result->{'response'}->{'status'}->{'code'} == 0 ) {
            push @artists, pop $result->{'response'}->{'artists'};
        }
    }

    #TODO: generate playlist from the artists
    #check: https://developers.google.com/youtube/v3/

    my $message = "Events";
    if ( defined $day && defined $month ) {
        $message = sprintf( '%s for %s of %s', $message, $day, $month );
    }

    $self->render( message => $message );
}

1;
