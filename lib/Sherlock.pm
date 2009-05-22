package Sherlock;
use strict;
use warnings;

our $VERSION = '0.01';

use Cache::Memcached::Fast;

my $LOCK_KEY = 'sherlock_%s';
my $EXPIRE   = 60*60*24; # 24H lock

sub new {
    my ($class, %args) = @_;
    
    return bless {
        lock_key => $args{lock_key} || $LOCK_KEY,
        expire   => $args{expire}   || $EXPIRE,
        memd     => Cache::Memcached::Fast->new($args{connect_option}),
    }, $class;
}

sub memd { $_[0]->{memd} }

sub lock_key_gen {
    my ($self, $lock_key) = @_;
    sprintf($self->{lock_key}, $lock_key);
}

# FIXME: use gets/cas
sub lock {
    my ($self, $lock_key, $expire) = @_;
    $self->memd->set($self->lock_key_gen($lock_key), 1, ($expire||$self->{expire}));
}

sub release {
    my ($self, $lock_key) = @_;
    $self->memd->delete($self->lock_key_gen($lock_key));
}

sub locked {
    my ($self, $lock_key) = @_;
    $self->memd->get($self->lock_key_gen($lock_key));
}

=head1 NAME

Sherlock  - eazy shared lock system

=head1 SYNOPSIS

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

=head1 DESCRIPTION

eazy shared lock.

=head1 XXX

Sherlock is not typo!

=head1 AUTHOR

Atsushi Kobayashi <nekokak _at_ gmail _dot_ com>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
