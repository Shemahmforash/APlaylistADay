use Mojo::Base -strict;

use Test::More tests => 21;
use Test::Mojo;

my $t = Test::Mojo->new('APlaylistADay');

#correct top menu
$t->get_ok('/')->status_is(200)->text_is('html body div.container div.row div.col-md-12 nav.navbar div.collapse ul.nav li.active a' => 'Events', 'Events selected in top menu');
$t->get_ok('/playlist')->status_is(200)->text_is('html body div.container div.row div.col-md-12 nav.navbar div.collapse ul.nav li.active a' => 'Playlist', 'Playlist selected in top menu');

#datepicker
$t->get_ok('/')->status_is(200)->element_exists('html body div.container div.row div.col-md-12 nav.navbar div.collapse ul.nav li.nav-choice input', 'Datepicker is present');
$t->get_ok('/playlist')->status_is(200)->element_exists_not('html body div.container div.row div.col-md-12 nav.navbar div.collapse ul.nav li.nav-choice', 'Datepicker is not present');

#correct page header
$t->get_ok('/')->status_is(200)->text_like('html body div.container div.row div.col-md-12 div.page-header h1 small' => qr/Events/, 'Events in page header');
$t->get_ok('/playlist')->status_is(200)->text_like('html body div.container div.row div.col-md-12 div.page-header h1 small' => qr/Playlist/, 'Playlist in page header');

#pagination
$t->get_ok('/')->status_is(200)->text_is('html body div.container div.row div.col-md-12 div.text-center ul.pagination li.active span' => 1, 'First page selected by default');
