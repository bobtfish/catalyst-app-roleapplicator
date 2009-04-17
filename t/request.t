use strict;
use warnings;
use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/lib";

use Catalyst::Test 'TestApp';

{
    my $resp = request('/foo/request');
    ok($resp->is_success);
    like($resp->content, qr/Catalyst::Request::Role::Foo/);
    like($resp->content, qr/TestApp::Request::Role::Bar/);
}
