package APlaylistADay::Track;

use Moose;
use MooseX::Privacy;
use Data::Dumper;

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

#TODO: convert to youtube api search
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

    my $log = Mojo::Log->new;
    $log->error( 'Error connecting to echonest: '
            . $result->{'response'}->{'status'}->{'message'} );

    return;
};

no Moose;
__PACKAGE__->meta->make_immutable;
