package APlaylistADay::Track;

use Moose;

use namespage::autoclean;

has 'artist' => (
    is      => 'ro',
    isa     => 'Str',
);

has 'name'   => (
    is      => 'ro',
    isa     => 'Str',
);

has 'album'  => (
    is      => 'ro',
    isa     => 'Str',
);

has 'source' => (
    is      => 'ro',
    isa     => 'Str',
);

has 'event' => (
    is      => 'ro',
    isa     => 'Event',
);

no Moose;                          
__PACKAGE__->meta->make_immutable;
