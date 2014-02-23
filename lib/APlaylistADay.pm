package APlaylistADay;
use Mojo::Base 'Mojolicious';

use Data::Dumper;

# This method will run once at server start
sub startup {
    my $self = shift;

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
    $r->get('/event/')->to('event#get');

=for

    $r->get('/')->to('playlist#get');
    $r->get('/:page')->to('playlist#get');
    $r->get('/playlist/')->to('playlist#get');
    $r->get('/playlist/:day/:month')->to('playlist#get');
    $r->get('/playlist/:day/:month/:page')->to('playlist#get');
=cut
}

1;
