package WWW::CPANTS::Web::Controller::Dist;

use WWW::CPANTS;
use WWW::CPANTS::Web::Util;
use WWW::CPANTS::Web::Util::Badge;
use WWW::CPANTS::Web::Util::BadgeSVG;
use parent 'Mojolicious::Controller';

sub index ($c) {
    my $author = $c->param('author') // '';
    my $name   = $c->param('name');

    my $format = '';
    if ($name =~ s/\.(json|png|svg)$//) {
        $format = $1;
        $c->param(name => $name);
        $c->stash(format => $format);
    }
    my $data = page('Dist')->load("$author/$name") or return $c->reply->not_found;

    if ($format eq 'json') {
        return $c->render(json => $data->{data});
    }
    if ($format eq 'png') {
        my $path = WWW::CPANTS::Web::Util::Badge->new($data->{data}{distribution}{core_kwalitee})->path;
        $c->res->headers->cache_control('max-age=1, no-cache');
        return $c->reply->static($path);
    }
    if ($format eq 'svg') {
        my $path = WWW::CPANTS::Web::Util::BadgeSVG->new($data->{data}{distribution}{core_kwalitee})->path;
        $c->res->headers->cache_control('max-age=1, no-cache');
        return $c->reply->static($path);
    }
    $c->stash(cpants => $data);
    $c->render('dist');
}

sub tab ($c) {
    my $author   = $c->param('author') // '';
    my $name     = $c->param('name');
    my $tab      = $c->param('tab');
    my $tabclass = camelize($tab);
    $c->reply->not_found unless $tabclass =~ /^[A-Za-z0-9]+$/;

    my $page = $c->param('page');
    my $data = page("Dist\::$tabclass")->load("$author/$name", $page) or return $c->reply->not_found;

    my $format = $c->stash('format') // '';
    if ($format eq 'json') {
        return $c->render(json => $data->{data});
    }
    $c->stash(cpants => $data);
    $c->render("dist/$tab");
}

1;
