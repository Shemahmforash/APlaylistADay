package APlaylistADay::Event;

use DateTime;
use Mojo::Base 'Mojolicious::Controller';
use Moose;

use Data::Dumper;

has 'date' => (
    is      => 'rw',
    isa     => 'DateTime',
    default => sub { return DateTime->now() },
);

sub get {
    my $self = shift;

    #TODO: check validity of day and month
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
    my $results = $self->events->find(
        'day'   => $self->date->day,
        'month' => $self->date->month_name
    );

    #respond to several content-types
    $self->respond_to(
        json => { json => $results },
        html => sub {
            $self->render(
                'results' => $results,
                'page'    => 0, 
                'date'    => $self->date->strftime('%B, %e')
            );
        },
        any => { text => '', status => 204 }
    );
}

1;
