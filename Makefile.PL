use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION   => '0.01',
    NAME      => 'aplaylist_aday',
    EXE_FILES => ['script/aplaylist_aday'],
    PREREQ_PM => { 'Mojolicious' => '4.58' },
    test      => { TESTS => 't/*.t' }
);
