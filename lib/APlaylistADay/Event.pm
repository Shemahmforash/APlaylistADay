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

has 'echonest_api_key' => (
    is        => 'ro',
    isa       => 'Str',
    traits    => [qw/Private/],
    'default' => '2FOIUUMCRLFMAWJXT',
);

has 'echonest_extract' => (
    is        => 'ro',
    isa       => 'Str',
    traits    => [qw/Private/],
    'default' => 'http://developer.echonest.com/api/v4/artist/extract',
);

has 'track' => (
    is     => 'rw',
    isa    => 'APlaylistADay::Track',
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

        my $track = APlaylistADay::Track->new( 'artist' => $self->artist );

        $self->track( $track );
    }
}

private_method find_event_artist => sub {
    my $self = shift;

    my $text = URI::Escape::uri_escape( $self->description() );

    #find artists in string, ordered by hottness
    my $url
        = sprintf(
        "%s?api_key=%s&format=json&results=1&sort=hotttnesss-desc&text=%s",
        $self->echonest_extract, $self->echonest_api_key, $text, );

    my $ua     = Mojo::UserAgent->new;
    my $json   = $ua->get($url);
    my $result = $json->res->json;

    #no error in call
    if ( $result->{'response'}->{'status'}->{'code'} == 0 ) {
        my $artist = shift $result->{'response'}->{'artists'};

        return $artist->{'name'};
    }
    else {
        my $log = Mojo::Log->new;
        $log->error( 'Error connecting to echonest: '
                . $result->{'response'}->{'status'}->{'message'} );
    }

    return;
};

no Moose;
__PACKAGE__->meta->make_immutable;
