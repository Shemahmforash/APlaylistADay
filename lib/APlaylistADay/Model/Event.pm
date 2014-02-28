package APlaylistADay::Model::Event;

use Moose;
use DateTime;
use JSON qw(decode_json);

use WebService::ThisDayInMusic;

use Data::Dumper;

use namespace::autoclean;

sub find {
    my ( $self, $day, $month ) = @_;

    my $dayinmusic = WebService::ThisDayInMusic->new();

    my $events = $dayinmusic->get(
        'action' => 'event',
        'day'    => $day,
        'month'  => $month
    );

    return $events;
}

no Moose;
__PACKAGE__->meta->make_immutable;
