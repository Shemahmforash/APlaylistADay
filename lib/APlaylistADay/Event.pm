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

sub model {
    return 'events';
}

sub get {
    my $self = shift;

    my $log = Mojo::Log->new;

    my ( $day, $month, $page ) = (
        $self->stash('day'), $self->stash('month'),
        defined $self->stash('page') ? $self->stash('page') : 1
    );

    #validates parameters
    my $validation = $self->_validate_parameters(
        'page'  => $page,
        'day'   => $day,
        'month' => $month
    );
    return $self->render_exception( $validation->{'status'} )
        if $validation->{'is_error'};

    my $date = DateTime->now();
    if ( $month && $day ) {
        my $epoch = Date::Parse::str2time("$day $month 2014");

        $date = DateTime->from_epoch(
            'epoch'     => $epoch,
            'locale'    => 'en_GB',
            'time_zone' => 'local',
        );
    }
    $self->date($date);

    my $offset = ( $page ? $page - 1 : 0 )
        * $self->config->{'playlist'}->{'results'};

    my $model = $self->model();

    my @args = ( $self->date->day, $self->date->strftime('%m'), $offset, );

    push @args, $self->config->{'playlist'}->{'results'}
        if $model eq 'events';

    my $results = $self->$model->find( @args, );

    #process errors
    if (   $results->{'is_error'}
        || $results->{'data'}->{'response'}->{'status'}->{'code'} != 0 )
    {

        my $message = "Error contacting webservice";

        $message = $results->{'data'}->{'response'}->{'status'}->{'status'}
            if $results->{'data'};

        $log->error($message);

        return $self->render_exception($message);
    }

    $results = $results->{'data'};

    my $pages
        = $self->_pages_2_render( $self->config->{'playlist'}->{'results'},
        $results->{'response'}->{'pagination'}->{'total'}, $page );

    #respond to several content-types
    $self->respond_to(
        json => { json => $results },
        html => sub {
            $self->render(
                'results' => $results,
                'page'    => $page,
                'pages'   => $pages,
                'date'    => $self->date,
            );
        },
        any => { text => '', status => 204 }
    );
}

sub _pages_2_render {
    my ( $self, $pagesize, $total, $page ) = @_;

    $page ||= 1;

    my $total_pages = ceil( $total / $pagesize );

    my @pages = 1 .. $total_pages;

    return \@pages,;
}

sub _validate_parameters {
    my $self = shift;
    my %arg  = @_;

    my $page  = $arg{'page'};
    my $day   = $arg{'day'};
    my $month = $arg{'month'};

    my $error;

    my $log = Mojo::Log->new;

    if ( $page !~ /\d+/ || $page < 1 ) {
        $error = "Page ( $page ) must be a positive integer";
        $log->error($error);
    }

    if ( $day && ( $day !~ /\d+/ || $day < 1 || $day > 31 ) ) {
        $error
            = "Day ( $day ) must be a positive integer in the interval [1,31]";
        $log->error($error);
    }

    if ( $month && $month !~ /\w+/ ) {
        $error = "Month ( $month ) must be a string";
        $log->error($error);
    }

    my %result = ( 'is_error' => $error ? 1 : 0, );

    $result{'status'} = $error
        if $error;
}

1;
