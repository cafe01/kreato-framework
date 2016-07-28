package Kreato::API::Websites;

use Mojo::Base -base;
use Carp;

has 'c';


sub find_by_hostname {
    my ($self, $hostname) = @_;

    my $db = $self->c->app->system_db;
    my $deployment = $db->resultset('Deployment')->find({ hostname => $hostname });

    return unless $deployment;

    my $website = $deployment->get('website');
    wantarray ? ($website, $deployment) : $website;
}


sub create {
    my ($self, $data) = @_;

    # required fields:
    # - name
    # - hostname
    # - owner
    # - developers (at least one)

    # optional:
    # - billing_contact
    # - disk_path
    # - redirect_url

    for (qw/ name hostname owner developers /) {

        croak "error: missing required field '$_'\n"
            unless defined $data->{$_};
    }

    croak "error: empty 'developers' list"
        unless $data->{developers}->[0];

    my $db = $self->c->app->system_db;
    my $websites = $db->resultset('Website');
    my $deployments = $db->resultset('Deployment');

    # error: hostname already exists
    die "hostname already exists"
        if $deployments->count({ hostname => $data->{hostname} });


    # insert
    my %deployment_data = map { $_ => delete $data->{$_} }
        qw/ hostname disk_path redirect_url/;

    my %website_data = map { $_ => delete $data->{$_} }
        qw/ name owner developers billing_contact /;

    $website_data{deployments} = \%deployment_data;

    $websites->create(\%website_data);
}



1;
