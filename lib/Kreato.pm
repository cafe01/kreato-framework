package Kreato;
use Mojo::Base 'Mojolicious';
use lib "$ENV{HOME}/workspace/DBIx-EAV/lib";
use lib "$ENV{HOME}/workspace/Plift/lib";
use lib "$ENV{HOME}/workspace/Mojolicious-Plugin-Plift/lib";

use File::Basename 'dirname';
use File::Spec;
use File::Spec::Functions qw'rel2abs catdir';
use File::ShareDir 'dist_dir';
use Cwd;
use Class::Load 'load_class';
use Mojo::Home;
use DBI;
use DBIx::EAV;


has dbh => sub {
    my $self = shift;

    my $dbh = DBI->connect(@{ $self->config }{ qw/db_dsn db_username db_password db_options/ })
        or die "Could not connect to database using DSN " . $self->config->{db_dsn};

    return $dbh;
};

has home => sub {
    my $path = $ENV{KREATO_HOME} || getcwd;
    return Mojo::Home->new(File::Spec->rel2abs($path));
};

has config_file => sub {
    my $self = shift;
    return $ENV{KREATO_CONFIG} if $ENV{KREATO_CONFIG};
    return $self->home->rel_file('kreato.conf');
};

has websites_dir => sub {
    my $self = shift;
    $self->config->{websites_dir} || $self->home->rel_dir('websites');
};

has share_dir => sub {
    my $self = shift;
    # use "local" share dir or dist share dir
    my $dir = catdir(dirname(rel2abs(__FILE__)), '..', 'share');
    -d $dir ? $dir : dist_dir('Kreato');
};

sub load_config {

    my $app = shift;

    $app->plugin( Config => {
        file    => $app->config_file,
        default => {
            db_dsn => 'dbi:SQLite:dbname=' . $app->home->rel_file('kreato.db'),
            db_username => undef,
            db_password => undef,
            db_options  => { sqlite_unicode => 1 },
            secrets     => [],
            upload_path => 'uploads',
        },
    });

    if ( my $secrets = $app->config->{secrets} ) {
        $app->secrets($secrets) if @$secrets;
    }
}



# This method will run once at server start
sub startup {
    my $app = shift;

    # load config file
    $app->load_config;

    # set public and template paths
    {
        my $share_dir = $app->share_dir;
        $app->static->paths->[0]   = catdir($share_dir, 'default/public');
        $app->renderer->paths->[0] = catdir($share_dir, 'default/templates');
    }

    # use commands from Kreato::Command namespace
    push @{$app->commands->namespaces}, 'Kreato::Command';

    ## Plugins
    $app->plugin('Humane', { auto => 1 });

    # Plift renderer
    my @widgets = map { '+Kreato::Widget::'.$_} qw/ Menu /;

    $app->plugin('Plift', {
        plugins => \@widgets
    });

    # VHost
    $app->plugin('Kreato::Plugin::VHost');
    # $app->plugin('Kreato::Plugin::SiteMap');
    # $app->plugin('Kreato::Plugin::Forms');
    # $app->plugin('Kreato::Plugin::JS');
    # $app->plugin('RPCHelpers');               # expose server helpers via client-side js-api, comunicates via ajax or w
    # $app->plugin('ActionClosure');            # save a subroutine to execute in a later request

    # TODO DeveloperTools plugin
    # - database explorer (webapp)

    # $app->renderer->default_handler('plift');

    ## Helpers ##

    $app->helper( system_db => \&_system_db );
    # api
    $app->helper( api => \&_load_api );

    # user
    $app->helper( user => sub { ... } );

    # website
    $app->helper( website => sub { ... } );

    # website sitemap
    $app->helper( sitemap => sub { ... } );

    # website skin
    $app->helper( skin => sub { ... } );

    # website database
    $app->helper( db => sub { ... } );

    ## Routes ##
    my $r = $app->routes;

    # route: website backend
    $r->get('/.backend' => 'backend');

    # route: backoffice
    my $backoffice = $r->under(sub {

        # is backoffice hostname?
    });

    # $backoffice->get();



    # route: page renderer
    # TODO make plift renderer refuse non-html format
    $r->get('/:page' => [format => 0])->to('page#process', { page => 'index' });
}


sub _system_db {
    my $self = shift;

    state $db = DBIx::EAV->new(
        dbh => $self->app->dbh,
        tenant_id => 0         # 0 = SYSTEM TENANT :)
    );

    $db;
}

sub _load_api {
    my ($self, $api_name, $params) = @_;
    $params //= {};

    $params->{c} = $self;

    load_class('Kreato::API::'.$api_name)->new($params);
}




package Kreato::Page;
use Mojo::Base 'Mojolicious::Controller';

sub process {
    my $c = shift;
    my $page = $c->stash->{page};
    $c->render( template => 'page/'.$page, handler => 'plift');
}



1;

=encoding utf-8

=head1 NAME

Kreato - Websites framework and hosting platform

=head1 SYNOPSIS

    use Kreato;

=head1 DESCRIPTION

=head1 LICENSE

Copyright (C) Carlos Fernando Avila Gratz.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Carlos Fernando Avila Gratz E<lt>cafe@kreato.com.brE<gt>

=cut
