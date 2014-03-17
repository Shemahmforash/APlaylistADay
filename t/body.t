use Mojo::Base -strict;

use Test::More tests => 18;
use Test::Mojo;

my $t = Test::Mojo->new('APlaylistADay');

#correct page header
$t->get_ok('/')->status_is(200)->text_like('html body div.container div.row div.col-md-12 div.page-header h1 small' => qr/Events/, 'Events in page header');
$t->get_ok('/event')->status_is(200)->text_like('html body div.container div.row div.col-md-12 div.page-header h1 small' => qr/Events/, 'Events in page header');
$t->get_ok('/playlist')->status_is(200)->element_exists('html body div.container div.row div.col-sm-6 iframe', 'Playlist exists in page');
$t->get_ok('/event')->status_is(200)->element_exists_not('html body div.container div.row div.col-sm-6 iframe', 'Playlist exists not in page');
$t->get_ok('/playlist')->status_is(200)->element_exists('html body div.container div.row div.col-sm-6 div.well ul li', 'At least one event besides playlist');
$t->get_ok('/event')->status_is(200)->element_exists('html body div.container div.row div.col-md-12 div.media div.media-body', 'At least one event in events list');
