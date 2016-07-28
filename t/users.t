#!/usr/bin/env perl
use Kreato::Test;

app->deploy_database;

my $api = app->api('Users');

isa_ok $api, 'Kreato::API::Users';


subtest 'Create user' => sub {

    # create
    my %data = (
        name => 'Carlos Fernando',
        email => 'cafe@foo.com',
        username => 'cafe',
        password => 'cafe',
    );

    my $user = $api->create(\%data);

    is $user->type->name, 'User', 'entity type is "User"';

    # error: missing required field
    dies_ok {  $api->create({ name => 'Foo' }) } 'missing required field';

    # error: user exists
    dies_ok {  $api->create({ %data, email => 'other' }) } 'unique username';
    dies_ok {  $api->create({ %data, username => 'other' }) } 'unique email';

    # user relationships
    is $user->get('roles')->count, 0, 'rel: roles';
    is $user->get('billing_websites')->count, 0, 'rel: billing_websites';
    is $user->get('owned_websites')->count, 0, 'rel: owned_websites';
    is $user->get('developer_websites')->count, 0, 'rel: developer_websites';
};



done_testing();
