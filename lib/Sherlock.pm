package Sherlock;
use strict;
use warnings;

our $VERSION = '0.01';

use DBI;

my $LOCK_KEY = 'sherlock_%s';
my $EXPIRE   = 60*60*24; # 24H lock

sub new {
    my ($class, $args) = @_;

    my $self = bless {
        lock_key => $args->{lock_key} || $LOCK_KEY,
        expire   => $args->{expire}   || $EXPIRE,
        dbh      => $args->{dbh}      || '',
        connect_option => $args->{connect_option},
    }, $class;

    $self->_connect;
    $self;
}

sub dbh { $_[0]->{dbh} }
sub _connect {
    my $self = shift;
    $self->{dbh} ||= DBI->connect(
        $self->{connect_option}->{dsn},
        $self->{connect_option}->{username},
        $self->{connect_option}->{password},
    ) or die 'cant connect';
}

sub lock_key_gen {
    my ($self, $lock_key) = @_;
    sprintf($self->{lock_key}, $lock_key);
}

sub lock {
    my ($self, $lock_key, $expire) = @_;

    $self->dbh->do('SELECT GET_LOCK(?,?)', {}, $self->lock_key_gen($lock_key), ($expire||$self->{expire}));
}

sub release {
    my ($self, $lock_key) = @_;
    $self->dbh->do('SELECT RELEASE_LOCK(?)', {}, $self->lock_key_gen($lock_key));
}

sub callback {
    my ($self, $lock_key, $args, $expire) = @_;

    while (1) {
        if ($self->lock($lock_key, $expire)) {
            $args->{code}->();
            $self->release($lock_key);
        }
        if (--$args->{try_cnt} <= 0) {
            last;
        }
        sleep(1);
    }
}

=head1 NAME

Sherlock  - eazy shared lock system

=head1 SYNOPSIS

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
  # or
  my $locker = Sherlock->new({dbh => $dbh});

  $locker->callback(
      hoge => +{
          code => sub {
              # do some process...
          },
      }, 10,
  );

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
