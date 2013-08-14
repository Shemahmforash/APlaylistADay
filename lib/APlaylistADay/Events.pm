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

    #TODO: find artists from events
    #TODO: generate playlist from the artists

    my $message = "Events";
    if ( defined $day && defined $month ) {
        $message = sprintf( '%s for %s of %s', $message, $day, $month );
    }

    $self->render( message => $message );
}

1;
