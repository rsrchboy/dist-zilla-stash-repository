package Dist::Zilla::Role::Git::ConfigFromStash;

# ABSTRACT: Helper to get git information into plugins via %Repository

use Moose::Role;
use namespace::autoclean;
use MooseX::AttributeShortcuts;
use Moose::Util::TypeConstraints 'role_type', 'class_type';

use Dist::Zilla::Stash::Repository;
use Dist::Zilla::Role::Stash::Repository;

# debugging...
#use Smart::Comments '###';

=attr stash

Our configured stash.  If one has been defined in the local C<dist.ini> or
user global C<~/.dzil>, then that will be used; if not a new stash is created
and registered.

Note that this behaviour is likely to change, and start exploding at some
point.

The stash attribute delegates to every method required by the interface role,
L<Dist::Zilla::Role::Stash::Repository>.

=cut

has _stash => (
    is  => 'lazy',
    isa => class_type('Dist::Zilla::Stash::Repository'),
    init_arg => undef,
    handles => role_type('Dist::Zilla::Interface::Stash::Repository'),
);

sub _build__stash {
    my ($self) = @_;

    ### @_

    my $stash = $self->zilla->stash_named('%Repository');
    return $stash if $stash;

    # otherwise, create it!
    $self->log('Warning: creating a %Repository stash on the fly!');

    # XXX this is evil, but I'm not quite sure how to get around it at the
    # moment
    $stash = Dist::Zilla::Stash::Repository->new;
    $self->zilla->_local_stashes->{'%Repository'} = $stash;

    return $stash;
}

!!42;

__END__

=head1 SYNOPSIS

    # in your dist.ini or ~/.dzil somewhere...
    [%Repository]

    # in your plugin class
    with 'Dist::Zilla::Role::Git::FromStash';

=head1 DESCRIPTION

This role helps plugins use configuration stashed in a, well, stash.  Its
purpose is to allow for the easy sharing of common configuration information,
objects, calculations and the like, without having to duplicate it across
every plugin, or requiring one plugin to query some other plugin.

=cut

