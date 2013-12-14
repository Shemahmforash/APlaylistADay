use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION   => '0.02',
    NAME      => 'aplaylist_aday',
    EXE_FILES => ['script/aplaylist_aday'],
    PREREQ_PM => {
        'HTTP::Message'                   => '6.03',
        'Mojolicious'                     => '4.58',
        'Moose'                           => '2.0603',
        'MooseX::Privacy'                 => '0.05',
        'WebService::EchoNest'            => '0.007',
        'JSON'                            => '2.53',
        'LWP::UserAgent'                  => '6.04',
        'LWP::Protocol::https'            => '6.03',
        'DateTime'                        => '0.75',
        'Redis'                           => '1.965'
    },
    test => { TESTS => 't/*.t' }
);
