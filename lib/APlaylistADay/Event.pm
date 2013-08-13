package APlaylistADay::Track;

use Moose;

use namespage::autoclean;

has 'date' => (
    is      => 'ro',
    isa     => 'Str',
);

has 'title' => (
    is      => 'ro',
    isa     => 'Str',
);

has 'description' => (
    is      => 'ro',
    isa     => 'Str',
);


no Moose;                          
__PACKAGE__->meta->make_immutable;
