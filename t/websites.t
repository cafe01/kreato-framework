#!/usr/bin/env perl
use Kreato::Test;

app->deploy_database;

my $api = app->api('Websites');

isa_ok $api, 'Kreato::API::Websites';


subtest 'Create website' => sub {

    my $user = app->api('Users')->create({
        name => 'Carlos Fernando Avila Gratz',
        email => 'cafe@foo.com',
        username => 'cafe',
        password => 'cafe',
    });

    # create
    my %data = (
        name => 'Website 01',
        owner => $user,
        billing_contact => $user,
        developers => [$user],
        hostname => 'website01.com'
    );

    my $site = $api->create(\%data);

    is $site->type->name, 'Website', 'entity type is "Website"';
    ok $site->in_storage, 'in_storage';

    # relationships
    is $site->get('developers')->first->id, $user->id, 'rel: developers';
    is $site->get('owner')->id, $user->id, 'rel: owner';
    is $site->get('billing_contact')->id, $user->id, 'rel: billing_contact';
    is $site->get('deployments')->first->get('hostname'), 'website01.com', 'rel: deployments';

    # error: missing required field
    dies_ok {  $api->create({ name => 'Foo' }) } 'missing required field';

    # error: already exists
    dies_ok {  $api->create({ %data, email => 'other' }) } 'unique hostname';
};


subtest 'find_by_hostname' => sub {


    my ($website, $deployment) = $api->find_by_hostname('website01.com');
    is $website->get('name'), 'Website 01';
    is $website->get('owner')->get('username'), 'cafe';


};



done_testing();
