package APlaylistADay::Event;

use Moose;
use MooseX::Privacy;
use APlaylistADay::Artist;
use URI::Escape ();
use WebService::EchoNest;
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

has 'artist_name' => (
    is  => 'rw',
    isa => 'Str',
);

has 'artist' => (
    is  => 'rw',
    isa => 'APlaylistADay::Artist',
);

sub find_event_artist {
    my ( $self, $echonest_key ) = @_;

    my $name = $self->artist_name;

    unless ($name) {
        my $text = URI::Escape::uri_escape( $self->description() );

        my $echonest = WebService::EchoNest->new( api_key => $echonest_key );

        my $data = $echonest->request(
            'artist/extract',
            'text'    => $text,
            'sort'    => 'hotttnesss-desc',
            'results' => 1,
            'format'  => 'json',
        );

        if ( $data->{'response'}->{'status'}->{'code'} == 0 ) {
            my $artist = shift $data->{'response'}->{'artists'};

            $name = $artist->{'name'};
        }
        else {
            my $log = Mojo::Log->new;
            $log->error( 'Error connecting to echonest: '
                    . $data->{'response'}->{'status'}->{'message'} );
        }

        $self->artist_name($name);
    }

    my $artist = APlaylistADay::Artist->new( 'name' => $name );
    $self->artist($artist);

    return $artist;
}

no Moose;
__PACKAGE__->meta->make_immutable;
