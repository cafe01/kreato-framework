package Kreato::API::Setup;

use Mojo::Base -base;

has 'c';


sub deploy_database {
    my $self = shift;
    my $schema = $self->c->app->system_db->schema;

    $schema->deploy;
    $self->register_system_entities;
}


sub register_system_entities {
    my $self = shift;
    my $db = $self->c->app->system_db;

    $db->register_types({

        User => {
            attributes   => [qw/ name email username password /],
            many_to_many => [
                'Role',
                [ developer_websites => 'Website', 'developers']
            ],
            has_many => [
                [ owned_websites   => 'Website', 'owner' ],
                [ billing_websites => 'Website', 'billing_contact' ]
            ]
        },

        Role => {
            attributes => [qw/ name display_name description /]
        },

        Website => {
            attributes => [qw/ name /],
            has_many   => ['Deployment']
        },

        Deployment => {
            attributes => [qw/ hostname disk_path redirect_url /]
        },

    });
}




1;
