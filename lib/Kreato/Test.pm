package Kreato::Test;

use strict;
use warnings;
use base 'Exporter';
use feature ();
use Test::More;
use Test::Exception;

our @EXPORT = (
    @Test::More::EXPORT,
    @Test::Exception::EXPORT,
    qw/ app /
);

our @EXPORT_OK = (
    @Test::More::EXPORT_OK,
    @Test::Exception::EXPORT_OK,
    qw/ build_test_app /
);


sub import {
    my ($pkg) = @_;

    # modern perl
    $_->import for qw(strict warnings utf8);
    feature->import(':5.10');

    # our stuff, via Exporter::export_to_level
    $pkg->export_to_level(1, @_);
}


my $app;
sub app {

    $app = build_test_app()
        unless defined $app;

    $app;
}

sub build_test_app {

    require Kreato;
    require DBI;
    my $app = Kreato->new( dbh => DBI->connect('dbi:SQLite:dbname=:memory:','','',{sqlite_unicode=>1}));
    $app->helper( deploy_database => sub {
        shift->api('Setup')->deploy_database;
    });

    $app;
}


1;
