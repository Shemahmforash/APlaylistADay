use Mojo::Base -strict;

use Test::More tests => 15;
use Test::Mojo;

my $t = Test::Mojo->new('APlaylistADay');

#correct top menu
$t->get_ok('/')->status_is(200)->text_is('html body div.container div.row div.col-md-12 nav.navbar div.collapse ul.nav li.active a' => 'Events', 'Events selected in top menu');
$t->get_ok('/playlist')->status_is(200)->text_is('html body div.container div.row div.col-md-12 nav.navbar div.collapse ul.nav li.active a' => 'Playlist', 'Playlist selected in top menu');

#datepicker
$t->get_ok('/')->status_is(200)->element_exists('html body div.container div.row div.col-md-12 nav.navbar div.collapse ul.nav li.nav-choice input', 'Datepicker is present');
$t->get_ok('/playlist')->status_is(200)->element_exists_not('html body div.container div.row div.col-md-12 nav.navbar div.collapse ul.nav li.nav-choice', 'Datepicker is not present');

$t->get_ok('/event/July/30/2')->status_is(200)->element_exists('html body div.container div.row div.col-md-12 nav.navbar div.collapse ul.nav li.nav-choice input[value="2014-07-30"]', 'Datepicker date is correct');
