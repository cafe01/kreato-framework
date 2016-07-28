#!/usr/bin/env perl
use Kreato::Test;

my $db  = app->system_db;

isa_ok $db, 'DBIx::EAV';

is $db->schema->tenant_id, 0, 'system tenant_id';

subtest 'System Entities' => sub {

    my $api = app->api('Setup');
    $api->deploy_database;
    ok defined $db->type($_) for qw/ User Role Website Deployment  /;
};


done_testing();
