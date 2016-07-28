use Mojo::Base 'Mojolicious::Command';

use Mojo::JSON 'j';
use Mojo::Util 'spurt';

has description => "Show websites, hostnames and users.";

sub run {
    my ( $self, @args ) = @_;

    my $app = $self->app;

}



1;


__END__

=pod

    kreato show websites --name=<name query> --hostname=<host query>

    kreato show users --website=<id> --name=<name query> --email=<email query>

    kreato show deployments --website=<id> --name=<name query>


=cut
