package APlaylistADay::Event;

use DateTime;
use Mojo::Base 'Mojolicious::Controller';
use Moose;
use MooseX::Privacy;
use WebService::ThisDayInMusic;
use WebService::Google::Freebase;
use Redis;

use APlaylistADay::Event;

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

    my $events = $self->find_events();
    die Dumper $events;
    
}

private_method find_events => sub {
    my $self = shift;

    my ( $day, $month ) = ( $self->date->day, $self->date->month_name );

    print STDERR $day, $month, "\n";

    my $dayinmusic = WebService::ThisDayInMusic->new();

    #limit to events of these types
    my $events = $dayinmusic->get( 'action' => 'event', 'day' => $day, 'month' => $month );

    return $events;
};

1;
