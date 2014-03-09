package APlaylistADay::Playlist;

use Moose;

extends 'APlaylistADay::Event';

sub model {
    return 'playlist';
}

1;
