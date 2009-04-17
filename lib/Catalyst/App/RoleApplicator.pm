package Catalyst::App::RoleApplicator;

use Moose::Exporter;
use Carp qw/confess/;
use Moose::Util qw/find_meta/;
use String::RewritePrefix;

use namespace::clean -except => 'meta';

Moose::Exporter->setup_import_methods;

my @attributes = map {
    [ $_, "${_}_class", "${_}_roles" ]
} qw/
    dispatcher
    request
    response
    stats
/;

sub init_meta {
    my ($class, %opts) = @_;

    my $caller = $opts{for_class};

    my $meta = find_meta($caller);
    confess 'oh noes' unless $meta;

    warn $meta->is_immutable;

    $caller->mk_classdata(map { $_->[2] } @attributes);
    warn("Made " . join(', ', map { $_->[2] } @attributes));
    $meta->add_after_method_modifier(setup_finalize => sub {
        warn("In setup finalize");
        my ($app) = @_;
        for my $attr (@attributes) {
            use Data::Dumper;
            warn("ATTR " . Dumper($attr));
            my $roles = $app->${ \$attr->[2] };
            warn("Attr $attr roles $roles");
            next unless $roles;
            warn("work out LOAD");
            my @to_load = map {
                    warn($attr->[0], $_);
                    $_ = $app->_transform_role_name($attr->[0], $_);
                    warn("Load $_");
                } @{ $roles };
            warn("Pre load");
            Class::MOP::load_class($_) for @to_load;
            warn("loaded");
            my $superclass = $app->${ \$attr->[1] };

            # hack: context_class doesn't have a default until the
            #       first request
            $superclass = $app
                if $attr->[0] eq 'context' && !$superclass;
            warn("Superclass $superclass");
            my $meta = Class::MOP::Class->create_anon_class(
                superclasses => [ $superclass ],
                roles        => $roles,
                cache        => 1,
            );
            warn("Made meta $meta " . $meta->name);
            $meta->add_method(meta => sub { $meta });
            warn("Added meta");
            $app->${ \$attr->[1] }($meta->name);
            warn("Assigned");
        }
        warn("Finished setup_finalize");
    });
    warn("adding trn method");
    $meta->add_method(_transform_role_name => sub {
        my ($app, $kind, $short) = @_;
        my $part = ucfirst $kind;
        return String::RewritePrefix->rewrite(
            { ''  => qq{Catalyst::${part}::Role::},
            '~' => qq{${app}::${part}::Role::},
            '+' => '' },
            $short,
        );
    });
    warn("Done");
}

1;
