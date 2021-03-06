use strict;
use warnings;
use Test::More tests => 2;

use FindBin;
use lib "$FindBin::Bin/lib";

use Catalyst::Test 'TestApp';

{
    my $resp = request('/foo/request');
    ok($resp->is_success);
    is($resp->content, 'Catalyst::Request::Role::Foo, TestApp::Request::Role::Bar');
}
