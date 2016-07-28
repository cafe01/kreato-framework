#!/usr/bin/env perl
use Kreato::Test;
use Test::Mojo;
use FindBin;

my $t = Test::Mojo->new(app);

app->deploy_database;
create_test_sites();

# my $stash;
# $t->app->hook( after_dispatch => sub { $stash = shift->stash });

$t->get_ok('/', { Host => 'website.01' })
  ->status_is(200)
  ->content_like(qr'website 01 index');

$t->get_ok('/file.txt', { Host => 'website.01' })
  ->status_is(200)
  ->content_like(qr'website01 static file');

$t->get_ok('/', { Host => 'website.02' })
  ->status_is(200)
  ->content_like(qr'website 02 index');

$t->get_ok('/file.txt', { Host => 'website.02' })
  ->status_is(200)
  ->content_like(qr'website02 static file');

$t->get_ok('/', { Host => 'website.unknown' })
  ->status_is(404)
  ->content_is('Website not found.');


done_testing();



sub create_test_sites {

    app->websites_dir("$FindBin::Bin/websites");

    my $websites = app->api('Websites');

    my $user = app->api('Users')->create({
        name => 'Carlos Fernando',
        email => 'cafe@foo.com',
        username => 'cafe',
        password => 'cafe',
    });

    $websites->create({
        name => 'Website 01',
        hostname => 'website.01',
        disk_path => 'website01',
        owner => $user,
        billing_contact => $user,
        developers => [$user]
    });

    $websites->create({
        name => 'Website 02',
        hostname => 'website.02',
        disk_path => 'website02',
        owner => $user,
        billing_contact => $user,
        developers => [$user]
    });
}
