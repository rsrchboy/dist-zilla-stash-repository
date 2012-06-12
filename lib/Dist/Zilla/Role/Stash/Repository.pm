package Dist::Zilla::Role::Stash::Repository;

# ABSTRACT: The defined interface of a Repository stash

use Moose::Role;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

with
    'Dist::Zilla::Role::Stash',
    'Dist::Zilla::Interface::Stash::Repository',
    ;

!!42;
