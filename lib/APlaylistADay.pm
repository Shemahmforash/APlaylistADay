package APlaylistADay;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # Everything can be customized with options
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

    # Normal route to controller
    $r->get('/')->to('example#welcome');
}

1;
