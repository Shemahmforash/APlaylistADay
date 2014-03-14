use Mojo::Base -strict;

use Test::More tests => 9;
use Test::Mojo;

my $t = Test::Mojo->new('APlaylistADay');

#correct page header
$t->get_ok('/')->status_is(200)->text_like('html body div.container div.row div.col-md-12 div.page-header h1 small' => qr/Events/, 'Events in page header');
$t->get_ok('/event')->status_is(200)->text_like('html body div.container div.row div.col-md-12 div.page-header h1 small' => qr/Events/, 'Events in page header');
$t->get_ok('/playlist')->status_is(200)->text_like('html body div.container div.row div.col-md-12 div.page-header h1 small' => qr/Playlist/, 'Playlist in page header');
