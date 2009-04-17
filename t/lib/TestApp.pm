package TestApp;

use Moose;

use namespace::clean -except => 'meta';
BEGIN { # I predict Scope::Upper before we're done here.

    extends 'Catalyst';
}
require Catalyst::App::RoleApplicator;
Catalyst::App::RoleApplicator->import;
__PACKAGE__->mk_classdata('request_roles');
__PACKAGE__->request_roles([qw/Foo ~Bar/]);

__PACKAGE__->setup;
warn("AFTER SETUP");

1;
