package Wx::Perl::EntryList::Iterator;

use strict;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors( qw(current list) );

sub attach {
    my( $self, $entrylist ) = @_;

    $self->list( $entrylist );
    $entrylist->add_subscriber( '*', $self, '_list_changed' );
}

sub detach {
    my( $self ) = @_;

    $entrylist->delete_subscriber( '*', $self );
}

sub _list_changed {
    my( $self, $list, $event, %args ) = @_;

    $list->_fixup_iterator( $self, $event, %args );
}

sub at_start { $_[0]->current == 0 }
sub at_end   { $_[0]->current >= $_[0]->list->count - 1 }

1;
