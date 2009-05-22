#! /usr/local/bin/perl
use strict;
use warnings;
use Sherlock;

my $locker = Sherlock->new(
    connect_option => +{
        servers => ['127.0.0.1:11211'],
    },
);

$locker->lock('hoge');

warn 'do hoge lock!';

if ($locker->locked('hoge')) {
    warn 'Yes locked!';
} else {
    warn 'No locked...';
}

$locker->release('hoge');

if ($locker->locked('hoge')) {
    warn 'Yes locked...';
} else {
    warn 'No locked!';
}

