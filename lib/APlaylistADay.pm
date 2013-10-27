package APlaylistADay;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    #keep application config
    my $config = $self->plugin(
        yaml_config => {
            file      => 'etc/config.yaml',
            stash_key => 'conf',
            class     => 'YAML::XS'
        }
    );
    $self->{'config'} = $config;

    # Router
    my $r = $self->routes;

    #all routes available
    $r->get('/')->to('playlist#get');
    $r->get('/:page')->to('playlist#get');
    $r->get('/playlist/')->to('playlist#get');
    $r->get('/playlist/:day/:month')->to('playlist#get');
    $r->get('/playlist/:day/:month/:page')->to('playlist#get');
}

1;
