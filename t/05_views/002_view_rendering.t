use Test::More import => ['!pass'];

use Dancer;
use lib 't';
use TestUtils;

my $time = time();

my @tests = (
    { path => '/',
      expected => "in view index.tt: number=\"\"\n" },
    { path => '/number/42',
      expected => "in view index.tt: number=\"42\"\n" },
    { path => '/clock', expected => "$time\n"},
    { path => '/request', expected => "/request\n" },
);

plan tests => scalar(@tests);

# we need Template to continue
eval "use Template";
SKIP: {
    skip "Template is required to test views", scalar(@tests) if $@;
    Template->import;

    # test simple rendering
    get '/' => sub {
        template 'index';
    };

    # test params.foo in view
    get '/number/:number' => sub {
        template 'index';
    };

    # test token interpolation
    get '/clock' => sub {
        template clock => { time => $time };
    };

    # test request.foo in view
    get '/request' => sub {
        template 'request'; 
    };

    foreach my $test (@tests) {
        my $path = $test->{path};
        my $expected = $test->{expected};
        
		my $request = fake_request(GET => $path);
        Dancer::SharedData->cgi($request);
        
		my $resp = Dancer::Renderer::get_action_response();
        is($resp->{content}, $expected, "content rendered looks good for $path");
    }
};
