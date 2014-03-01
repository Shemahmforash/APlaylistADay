package APlaylistADay::Event;

use Mojo::Base 'Mojolicious::Controller';

use POSIX;

use Moose;
use DateTime;
use Date::Parse;
use DateTime::Locale;
use Data::Dumper;

has 'date' => (
    is      => 'rw',
    isa     => 'DateTime',
    default => sub { return DateTime->now() },
);

sub get {
    my $self = shift;

    #TODO: check validity of day and month
    my ( $day, $month, $page ) = (
        $self->stash('day'), $self->stash('month'), $self->stash('page') > 0 ? $self->stash('page') : 1
    );

    my $date = DateTime->now();
    if ( $month && $day ) {
        my $epoch= Date::Parse::str2time(  "$day $month 2014" );

        $date = DateTime->from_epoch(
                        'epoch'     => $epoch,
                        'locale'    => 'en_GB',
                        'time_zone' => 'local',
                    );
    }
    $self->date($date);

    my $offset = ( $page ? $page - 1 : 0 ) * $self->config->{'playlist'}->{'results'};
    my $results = $self->events->find(
        $self->date->day,
        $self->date->strftime('%m'),
        $offset,
        $self->config->{'playlist'}->{'results'},
    );

    if( !$results || $results->{'status'}->{'code'} != 0 ) {
        #TODO: error page
    }

    my $pages = $self->_pages_2_render( $self->config->{'playlist'}->{'results'}, $results->{'response'}->{'pagination'}->{'total'}, $page );

    #don't allow out of range pages
    $page = $pages->[-1]
        if( $page > $pages->[-1] );

    #respond to several content-types
    $self->respond_to(
        json => { json => $results },
        html => sub {
            $self->render(
                'results' => $results,
                'page'    => $page, 
                'pages'   => $pages, 
                'date'    => $self->date->strftime('%B, %e')
            );
        },
        any => { text => '', status => 204 }
    );
}

sub _pages_2_render{
    my ( $self, $pagesize, $total, $page ) = @_;

    $page ||= 1;

    my $total_pages = 1 + floor( $total / $pagesize );

    my @pages = 1 .. $total_pages;

    return \@pages,
}

1;
