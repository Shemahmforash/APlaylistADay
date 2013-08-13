package APlaylistADay::Playlist;

use Moose;

use namespage::autoclean;

has 'tracks' => (
    is      => 'ro',
    isa     => 'Array[Track]',
);

no Moose;                          
__PACKAGE__->meta->make_immutable;
