package APlaylistADay::Model::Playlist;

use Moose;

extends 'APlaylistADay::Model::Event';

has 'action' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'playlist',
);

no Moose;
__PACKAGE__->meta->make_immutable;
