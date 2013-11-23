package APlaylistADay::Event;

use Moose;
use MooseX::Privacy;
use APlaylistADay::Track;
use Data::Dumper;

use namespace::autoclean;

has 'date' => (
    is  => 'ro',
    isa => 'Str',
);

has 'type' => (
    is  => 'ro',
    isa => 'Str',
);

has 'description' => (
    is  => 'ro',
    isa => 'Str',
);

has 'artist' => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

has 'track' => (
    is  => 'rw',
    isa => 'APlaylistADay::Track',
);

has 'echonest_api_key' => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [qw/Private/],
    required => 1,
);

has 'echonest_extract' => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [qw/Private/],
    required => 1,
);

#TODO: do not repeat this attributes in both Event and Track Classes
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

sub BUILD {
    my $self = shift;

    unless ( $self->artist ) {

        #find event artist on creating a new object
        my $artist = $self->find_event_artist();

        $self->artist($artist)
            if $artist;
    }

    if ( $self->artist ) {

        my $track = APlaylistADay::Track->new(
            'artist'                     => $self->artist,
            'google_api_key'             => $self->google_api_key,
            'youtube_search_url'         => $self->youtube_search_url,
            'freebase_google_search_url' => $self->freebase_google_search_url
        );

        $self->track($track);
    }
}

private_method find_event_artist => sub {
    my $self = shift;

    my $text = URI::Escape::uri_escape( $self->description() );

    my $echonest = WebService::EchoNest->new(
        api_key => $self->app->{config}->{'echonest'}->{'key'}, );

    my $data = $echonest->request(
        'artist/extract',
        'text'    => $text,
        'sort'    => 'hotttnesss-desc',
        'results' => 1,
        'format' => 'json',
    );

    my $artist;
    if ( $data->{'response'}->{'status'}->{'code'} == 0 ) {
        my $artist = shift $data->{'response'}->{'artists'};

        $artist = $artist->{'name'};
    }
    else {
        my $log = Mojo::Log->new;
        $log->error( 'Error connecting to echonest: '
                . $data->{'response'}->{'status'}->{'message'} );
    }

    return $artist;
};

no Moose;
__PACKAGE__->meta->make_immutable;
