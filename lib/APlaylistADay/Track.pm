package APlaylistADay::Track;

use Moose;
use MooseX::Privacy;
use Data::Dumper;
use WebService::Google::Freebase;
use WebService::Google::Youtube;

use namespace::autoclean;

#made rw attributes not be settable from outsite class: http://search.cpan.org/dist/Moose/lib/Moose/Manual/Attributes.pod#Accessor_methods
has 'artist' => (
    is       => 'ro',
    isa      => 'Str',
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

=for
#TODO: this variables should be received in the constructor from the app config
has 'echonest_api_key' => (
    is        => 'ro',
    isa       => 'Str',
    traits    => [qw/Private/],
    'default' => '2FOIUUMCRLFMAWJXT',
);

has 'echonest_video' => (
    is        => 'ro',
    isa       => 'Str',
    traits    => [qw/Private/],
    'default' => 'http://developer.echonest.com/api/v4/artist/video',
);
=cut

has 'google_api_key' => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [qw/Private/],
    required => 1,
);

has 'youtube_search_url' => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [qw/Private/],
    required => 1,
);

has 'freebase_google_search_url' => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [qw/Private/],
    required => 1,
);

my $log = Mojo::Log->new;

sub BUILD {
    my $self = shift;

    if ( $self->artist ) {

        my $track = $self->find_track();

        if ($track) {
            $self->title( $track->{'title'} );
            $self->id( $track->{'id'} );
        }
    }
}

private_method find_track => sub {
    my $self = shift;
    my $artist = shift || $self->artist;

    return unless $artist;

    $artist = URI::Escape::uri_escape($artist);

    my $topic = $self->find_artist_topic($artist);

    return unless $topic;

    my $youtube = WebService::Google::Youtube->new('key' => $self->google_api_key);

    my $result = $youtube->get('part' => 'snippet', 'topicId' => $topic, 'type' => 'video');

    return unless $result && scalar @{ $result->{'items'} };

    my $item = shift @{ $result->{'items'} || [] };

    my %track = (
        'id'    => $item->{'id'}->{'videoId'},
        'title' => $item->{'snippet'}->{'title'},
    );

    $track{'title'} = join ' - ', $track{'title'},
        $item->{'snippet'}->{'description'}
        if $item->{'snippet'}->{'description'};

    return \%track;
};

#finds the freebase topic related to the artist
private_method find_artist_topic => sub {
    my $self   = shift;
    my $artist = shift;

    my $freebase = WebService::Google::Freebase->new();

    my $results = $freebase->get(
        'query'   => $artist,
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

=for
private_method find_track => sub {
    my $self = shift;

    return unless $self->artist;

    my $url = sprintf( "%s?api_key=%s&format=json&name=%s&results=1",
        $self->echonest_video, $self->echonest_api_key, $self->artist, );

    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($url);
    my $result = $json->res->json;

    if ( $result->{'response'}->{'status'}->{'code'} == 0 ) {
        my $video = shift $result->{'response'}->{'video'}
            || return;

        if ( $video->{'url'} =~ m/v\=(\w+)\&/ ) {
            $video->{'id'} = $1;
            return $video;
        }
    }

    $log->error( 'Error connecting to echonest: '
            . $result->{'response'}->{'status'}->{'message'} );

    return;
};
=cut

no Moose;
__PACKAGE__->meta->make_immutable;
