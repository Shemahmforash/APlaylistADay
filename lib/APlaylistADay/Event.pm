package APlaylistADay::Event;

use Mojo::Base 'Mojolicious::Controller';

use Moose;
use DateTime;
use Date::Parse;
use DateTime::Locale;
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
        my $epoch= Date::Parse::str2time(  "$day $month 2014" );

        $date = DateTime->from_epoch(
                        'epoch'     => $epoch,
                        'locale'    => 'en_GB',
                        'time_zone' => 'local',
                    );
    }

    $self->date($date);

    my $results = $self->events->find(
        $self->date->day,
        $self->date->strftime('%m'),
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
