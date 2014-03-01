package APlaylistADay;
use Mojo::Base 'Mojolicious';

use APlaylistADay::Model::Event;
use APlaylistADay::Model::Playlist;

use Data::Dumper;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Helper to lazy initialize and store our model object
    $self->helper(events   => sub { state $events = APlaylistADay::Model::Event->new() });
    $self->helper(playlist => sub { state $events = APlaylistADay::Model::Playlist->new() });

    my $cfg = $self->plugin('JSONConfig', file => 'etc/config.json');

    #merging default environment config with current environment config
    my %config = %{ $cfg->{'development'} || {} };
    if ( $self->app->mode ne 'development' ) {
        %config = ( %config, %{ $cfg->{ $self->app->mode } } );
    }

    $self->{'config'} = \%config;

    # Router
    my $r = $self->routes;

    #all routes available
    $r->get('/')->to('event#get');
    $r->get('/about/')->to('about#show');
    $r->get('/event/')->to('event#get');
    $r->get('/event/:page')->to('event#get');
    $r->get('/event/:month/:day')->to('event#get');
    $r->get('/event/:month/:day/:page')->to('event#get');
    $r->get('/playlist/')->to('playlist#get');
    $r->get('/playlist/:month/:day')->to('playlist#get');
    $r->get('/:page')->to('event#get');
}

1;
