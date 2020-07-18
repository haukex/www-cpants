use Mojo::Base -strict, -signatures;
use WWW::CPANTS::Test;
use WWW::CPANTS::Test::Fixture;
use Test::More;
use Test::Mojo;

fixture {
    my @files = (
        'ISHIGAKI/JSON-4.02.tar.gz',
    );
    my $testpan = setup_testpan(@files);
    $testpan->cpan->update_indices;

    load_task('UpdateCPANIndices::Whois')->run;
    load_task('Traverse')->run(qw/ISHIGAKI/);
    load_task('Analyze')->run(@files);
    load_task('PostProcess')->run;
};

subtest 'get' => sub {
    my $t = Test::Mojo->new('WWW::CPANTS::Web');
    $t->get_ok('/search')->status_is(200);
};

done_testing;
