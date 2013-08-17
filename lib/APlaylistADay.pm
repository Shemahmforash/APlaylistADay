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
    $r->get('/')->to('events#get');
    $r->get('/events/')->to('events#get');
    $r->get('/events/:day/:month')->to('events#get');
}

1;
