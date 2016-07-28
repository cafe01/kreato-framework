package Kreato::API::Users;

use Mojo::Base -base;

has 'c';


sub find {
    my ($self, $where) = @_;

}

sub create {
    my ($self, $data) = @_;

    # required fields
    for (qw/ name username email password /) {

        die "missing required field '$_'\n"
            unless defined $data->{$_};
    }

    my $users_rs = $self->c->app->system_db->resultset('User');

    # already exists
    my %unique = map { $_ => $data->{$_} } qw/ username email /;
    my $already_exists = $users_rs->count([%unique]);
    die "user already exists\n" if $already_exists;

    # all good, create the user
    $users_rs->create($data);
}

sub send_reset_password_email {
    my ($self, $user) = @_;
}

sub reset_password {
    my ($self, $user, $token) = @_;
}



1;
