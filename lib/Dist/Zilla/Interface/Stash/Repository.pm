package Dist::Zilla::Interface::Stash::Repository;

# ABSTRACT: The defined interface of a Repository stash

use Moose::Role;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

=required_method repo_root

=required_method repo

=required_method allow_dirty

=required_method changelog

=required_method version_regexp

=required_method has_previous_versions

=required_method previous_versions_count

=required_method earliest_version

=required_method first_version

=required_method last_version

=cut

requires $_ for qw{
    repo_root
    repo
    allow_dirty
    changelog
    version_regexp
    has_previous_versions
    previous_versions_count
    earliest_version
    first_version
    last_version
};

!!42;
__END__

=head1 SYNOPSIS

    # in an attribute somewhere...
    has foo => (
        is      => 'rw',
        handles => role_type('Dist::Zilla::Interface::Stash::Repository'),
    );

=head1 DESCRIPTION

This role defines the interface that
L<Dist::Zilla::Role::Stash::Repository|repository stashes> are expected to
implement.

=cut
