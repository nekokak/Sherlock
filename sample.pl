#! /usr/local/bin/perl
use strict;
use warnings;
use Sherlock;

my $locker = Sherlock->new(
    {
        connect_option => +{
            dsn      => "dbi:mysql:test",
            username => 'test',
            password => '',
        },
    }
);

$locker->callback(
    hoge => +{
        code => sub {
            warn 'get lock!';
            sleep (5);
            warn 'releaseeeeeee!';
        },
    }, 10,
);


