package APlaylistADay::Events;
use Mojo::Base 'Mojolicious::Controller';

sub get {
    my $self = shift;

    my ( $day, $month ) = ( $self->stash('day'), $self->stash('month') );

    my $message = "Events";
    if ( defined $day && defined $month ) {
        $message = sprintf( '%s for %s of %s', $message, $day, $month );
    }

    $self->render( message => $message );
}

1;
