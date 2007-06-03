package Wx::Perl::EntryList::FwBwIterator;

use strict;
use base qw(Wx::Perl::EntryList::Iterator);

sub next_entry {
    my( $self ) = @_;
    return if $self->at_end;

    $self->current( $self->current + 1 );
}

sub previous_entry {
    my( $self ) = @_;
    return if $self->at_start;

    $self->current( $self->current - 1 );
}

1;
