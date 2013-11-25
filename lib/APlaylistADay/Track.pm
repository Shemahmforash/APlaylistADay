package APlaylistADay::Track;

use Moose;
use MooseX::Privacy;
use Data::Dumper;

use namespace::autoclean;

#made rw attributes not be settable from outsite class: http://search.cpan.org/dist/Moose/lib/Moose/Manual/Attributes.pod#Accessor_methods
has 'artist' => (
    is       => 'ro',
    isa      => 'APlaylistADay::Artist',
    required => 1,
);

has 'title' => (
    is  => 'rw',
    isa => 'Str',
);

has 'album' => (
    is  => 'ro',
    isa => 'Str',
);

has 'id' => (
    is  => 'rw',
    isa => 'Str',
);

no Moose;
__PACKAGE__->meta->make_immutable;
