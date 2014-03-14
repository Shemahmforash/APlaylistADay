use Mojo::Base -strict;

use Test::More tests => 15;
use Test::Mojo;

my $t = Test::Mojo->new('APlaylistADay');

#pagination
$t->get_ok('/')->status_is(200)->text_is('html body div.container div.row div.col-md-12 div.text-center ul.pagination li.active span' => 1, 'First page selected by default');
$t->get_ok('/1')->status_is(200)->text_is('html body div.container div.row div.col-md-12 div.text-center ul.pagination li.active span' => 1, 'First page selected by default');
$t->get_ok('/2')->status_is(200)->text_is('html body div.container div.row div.col-md-12 div.text-center ul.pagination li.active span' => 2, 'Second page selected');
$t->get_ok('/event/1')->status_is(200)->text_is('html body div.container div.row div.col-md-12 div.text-center ul.pagination li.active span' => 1, 'First page selected');
$t->get_ok('/event/July/30/2')->status_is(200)->text_is('html body div.container div.row div.col-md-12 div.text-center ul.pagination li.active span' => 2, 'Second page selected');
