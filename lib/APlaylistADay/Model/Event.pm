package APlaylistADay::Model::Event;

use Moose;
use DateTime;
use JSON qw(decode_json);

use WebService::ThisDayInMusic;

use Data::Dumper;

use namespace::autoclean;

sub find {
    my ( $self, $day, $month, $offset, $results ) = @_;

    my %arg = (
        'action' => 'event',
        'day'    => $day,
        'month'  => $month
    );
    $arg{'offset'} = $offset
        if defined $offset;
    $arg{'results'} = $results
        if defined $results;

    $arg{'fields'} = [ qw(artist date description type ) ];

    my $dayinmusic = WebService::ThisDayInMusic->new();

    my $events = $dayinmusic->get(
        %arg
    );

    return $events;
}

no Moose;
__PACKAGE__->meta->make_immutable;
