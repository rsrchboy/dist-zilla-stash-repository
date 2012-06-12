package Dist::Zilla::Stash::Repository;

# ABSTRACT: The great new Dist::Zilla::Stash::Repository!

use Reindeer;
#use namespace::autoclean;

use List::Util 'first';
use Dist::Zilla 4 ();
use Git::Wrapper;
use Version::Next ();
use version 0.80 ();


=attr repo_root (type: Dir)

The root of the repository; defaults to the current working directory (aka
'.').

=attr allow_dirty (type: ArrayRef[File])

A list of files that are allowed to be dirty through and will be committed at
the end of the release process.

=attr changelog (type: File)

The project's changelog; defaults to 'Changes' in the repository root (see
C<repo_root>, above).

=cut

has repo_root   => (is => 'lazy', isa => Dir           );
has repo        => (is => 'lazy', isa => 'Git::Wrapper');
has allow_dirty => (is => 'lazy', isa => ArrayRef[File]);
has changelog   => (is => 'lazy', isa => File          );

sub _build_repo_root   { '.'                                 }
sub _build_repo        { Git::Wrapper->new(shift->repo_root) }
sub _build_allow_dirty { [ 'dist.ini', shift->changelog ]    }
sub _build_changelog   { file(shift->repo_root, 'Changes')   }

has version_regexp => (is => 'lazy', isa => Str);
has first_version  => (is => 'lazy', isa => Str);

sub _build_version_regexp { '^v(.+)$' }
sub _build_first_version  { '0.001'   }

has _previous_versions => (

    traits  => ['Array'],
    is      => 'lazy',
    isa     => 'ArrayRef[Str]',
    handles => {

        has_previous_versions   => 'count',
        previous_versions_count => 'count',
        previous_versions       => 'elements',
        earliest_version        => [ get =>  0 ],
        last_version            => [ get => -1 ],
    },
);

sub _build__previous_versions {
  my ($self) = @_;

  local $/ = "\n"; # Force record separator to be single newline

  #my $git  = Git::Wrapper->new( $self->repo_root );
  my $git = $self->repo;
  my $regexp = $self->version_regexp;

  my @tags = $git->tag;
  @tags = map { /$regexp/ ? $1 : () } @tags;

  # find tagged versions; sort least to greatest
  my @versions =
    sort { version->parse($a) <=> version->parse($b) }
    grep { eval { version->parse($_) }  }
    @tags;

  return [ @versions ];
}

with 'Dist::Zilla::Role::Stash::Repository';
#with 'Dist::Zilla::Role::Interface::Repository';

__PACKAGE__->meta->make_immutable;
!!42;
__END__

=head1 SYNOPSIS

    # in ~/.dzil/config.ini or (PREFERRED) dist.ini
    [%Repository]
    first_version = ...

    # in your plugin, easy access via:
    with 'Dist::Zilla::Role::Git::ConfigFromStash';

=head1 DESCRIPTION

This is a L<Dist::Zilla> stash designed to hold all the relevant information
about the repository your project resides in, to allow plugins to manipulate
it without having to duplicate plugin code and configuration all over the
place.

=head1 CAVEAT

When looking for stashes, L<Dist::Zilla> first looks in your "global" user
config at C<~/.dzil/config.ini> and then in your per-project C<dist.ini>.
This means that if you define settings for this stash in your global config,
they will override any project specific settings!

This is probably not a big deal if you're only working on your own projects;
however, it will make things difficult for other devs working on your project,
and will override any settings that may be in the C<dist.ini> of projects not
belonging to you.

The recommended way to configure this stash without these issues is to either
include it in each C<dist.ini> or your L<Dist::Zilla> plugin bundle, if you're
using a specific one.

=head1 INTERFACE

We implement the repository stash interface as defined by
L<Dist::Zilla::Interface::Stash::Repository>.

=cut

