package Kreato::Plugin::VHost;

use Mojo::Base 'Mojolicious::Plugin';
use File::Spec::Functions qw' catdir ';


my %defaults;


sub register {
    my ($plugin, $app) = @_;

    %defaults = (
        static   => $app->static->paths,
        renderer => $app->renderer->paths,
    );

    $app->hook(
        before_dispatch => \&detect_website
    );
}

sub detect_website {
    my $c = shift;
    my $app = $c->app;

    my $hostname = $c->tx->req->headers->host;

    my $websites = $app->api('Websites');
    my ($website, $deployment) = $websites->find_by_hostname($hostname);

    # not found
    unless ($website) {

        $app->log->debug("No website detected via hostname '$hostname'");
        _set_defaults($app);
        $c->res->code(404);
        return $c->render(text => 'Website not found.');

    }

    # stash
    $c->stash( website => $website );
    $app->log->debug("Detected website '@{[ $website->get('name') ]}' via '$hostname'");

    # redirect
    if (my $redirect_url = $deployment->get('redirect_url')) {
        return $c->redirect_to($redirect_url);
    }

    # has deployment
    if ( my $deployment_path = $deployment->get('disk_path') ) {

        $app->log->debug("Website deployment dir: $deployment_path");

        my $websites_dir = $app->websites_dir;
        my $static       = catdir($websites_dir, $deployment_path, 'public');
        my $templates    = catdir($websites_dir, $deployment_path, 'templates');

        $app->static->paths([ $static, @{$defaults{static}}  ]);
        $app->renderer->paths([ $templates, @{$defaults{renderer}}  ]);
    }

    # website created but not deployed yet
    else {

    }
}

sub _set_defaults {
    my ($app) = @_;

    $app->static->paths($defaults{static});
    $app->renderer->paths($defaults{renderer});
}



1;
