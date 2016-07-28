package Kreato::Command::setup;
use Mojo::Base 'Mojolicious::Command';

use Mojolicious::Command::daemon;

use Mojolicious::Routes;
use Mojo::JSON 'j';
use Mojo::Util 'spurt';
use File::Spec::Functions qw'catdir';

has description => "Configure your Kreato installation via a web interface\n";

sub run {
    my ( $self, @args ) = @_;

    my $app = $self->app;

    # add setup file paths
    unshift @{ $app->static->paths }, catdir( $app->share_dir, 'setup', 'public' );
    unshift @{ $app->renderer->paths }, catdir( $app->share_dir, 'setup', 'templates' );

    $app->defaults( layout => 'default', handler => 'plift' );

    ## Routes

    my $r = Mojolicious::Routes->new;
    $app->routes($r);

    $r->get('/' => 'welcome');

    $r->get('/configure');

    $r->post('/save_config' => sub {
        my $self  = shift;
        my $names = $self->req->params->names;

        # map JSON keys to Perl data
        my %params = map { $_ => scalar $self->param($_) } @$names;
        foreach my $key (qw/ db_options /) {
            $params{$key} = j( $params{$key} );
        }

        spurt $self->dumper( \%params ), $self->app->config_file;

        $self->app->load_config;
        $self->humane_flash('Configuration saved.');
        $self->redirect_to('/configure');
    });

    $r->get( '/database' => sub {
        my $self = shift;

        my $db = $self->app->system_db;

        # Nothing installed
        my $installed = $db->schema->version_table_is_installed;
        return $self->render('database')
            unless $installed;

        # Something is installed, check for upgrades
        my $available = $db->schema->version;

        # Do nothing if version is current
        if ( $installed == $available ) {
            $app->log->debug('Schema is already deployed');
            $self->humane_flash('Database schema is current.');
        }
        else {
            die "upgrade not implemented";
        }

        $self->redirect_to('finish');
    });

    $r->post('/database_install' => sub {
        my $self = shift;
        my $pw1  = $self->param('pw1');
        my $pw2  = $self->param('pw2');
        my $api  = $app->api('Setup');

        unless ($api->database_is_installed) {
            $api->deploy_database;
            $self->flash( 'message' => 'Database has been setup.' );
        }

        # eval {
        #     my $user = $self->param('username')
        #         || die "Admin Username is required\n";
        #
        #     my $name = $self->param('name')
        #         || die "Admin Name is required\n";
        #
        #     die qq{Passwords don't match!\n}
        #         unless length $pw1 && $pw1 eq $pw2;
        # };
        #
        # if ($@) {
        #     my $error = "$@";
        #     chomp $error;
        #     $self->humane_flash($error);
        #     return $self->redirect_to('database');
        # }

        $self->redirect_to('finish');
    });

    $r->get('/finish' => sub {
        my $self = shift;
        my $message = $self->flash('message');

        my $schema    = $app->system_db->schema;
        my $installed = $schema->installed_version;
        my $available = $schema->version;
        # my $has_admin = $db->has_admin_user;

        if ($installed) {
            # unless ($has_admin) {
            #     $message .= ' No administration user was created.';
            # }
            unless ( $installed == $available ) {
                $message .= " Installed database version ($installed) is older than the newest available ($available).";
            }
            $self->stash( 'success' => 1 );
            $self->stash( 'message' => $message );
        }
        else {
            $self->stash( 'success' => 0 );
            $self->stash( 'message' => 'It does not appear that your database is setup, please rerun the setup utility'
            );
        }

        $self->humane_stash('Goodbye');
        $self->render('finish');
        $self->tx->on( finish => sub { exit } );
    } );

    $self->Mojolicious::Command::daemon::run(@args);
}

1;
