package APlaylistADay::Artist;

use Moose;
use MooseX::Privacy;
use APlaylistADay::Track;
use WebService::Google::Freebase;
use WebService::Google::Youtube;
use URI::Escape ();
use Data::Dumper;

use namespace::autoclean;

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has 'track' => (
    is  => 'rw',
    isa => 'APlaylistADay::Track',
);

has 'freebase_topic' => (
    is     => 'rw',
    traits => [qw/Private/],
    isa    => 'Str',
);

#using google freebase and google youtube apis, finds a video for the current artist
sub find_track {
    my ( $self, $google_key ) = @_;

    my $topic = $self->find_artist_topic()
        || return;

    $self->freebase_topic($topic);

    my $track = $self->find_track_video($google_key) || return;

    $self->track($track);

    return $track->id;
}

#finds freebase topic for the artist name
private_method find_artist_topic => sub {
    my $self = shift;

    my $freebase = WebService::Google::Freebase->new();
    my $results  = $freebase->get(
        'query'   => URI::Escape::uri_escape( $self->name ),
        'lang'    => 'en',
        'indent'  => 'true',
        'filters' => '(any type:/music/artist)',
    );

    my $topic;
    $topic = shift @{ $results || [] };

    return
        unless ref $topic eq 'HASH' && $topic->{'mid'};

    return $topic->{'mid'};
};

#finds youtube video for the artist
private_method find_track_video => sub {
    my ( $self, $google_key ) = @_;

    my $youtube = WebService::Google::Youtube->new( 'key' => $google_key );

    my $result = $youtube->get(
        'part'    => 'snippet',
        'topicId' => $self->freebase_topic,
        'type'    => 'video'
    );

    return unless $result && scalar @{ $result->{'items'} };

    my $item = shift @{ $result->{'items'} || [] };

    my %track = (
        'id'    => $item->{'id'}->{'videoId'},
        'title' => $item->{'snippet'}->{'title'},
    );

    $track{'title'} = join ' - ', $track{'title'},
        $item->{'snippet'}->{'description'}
        if $item->{'snippet'}->{'description'};

    my $track = APlaylistADay::Track->new(
        'artist'      => $self,
        'id'          => $item->{'id'}->{'videoId'},
        'title'       => $item->{'snippet'}->{'title'},
        'description' => $item->{'snippet'}->{'description'},
    );

    return $track;
};

no Moose;
__PACKAGE__->meta->make_immutable;
