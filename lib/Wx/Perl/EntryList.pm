package Wx::Perl::EntryList;

use strict;
use base qw(Class::Publisher Class::Accessor::Fast);

__PACKAGE__->mk_accessors( qw(entries) );

sub new {
    my( $class ) = @_;
    my $self = $class->SUPER::new( { entries => [] } );

    return $self;
}

sub get_entry_at { return $_[0]->entries->[ $_[1] ] }

sub _add_entries_at {
    my( $self, $index, $entries ) = @_;

    splice @{$self->entries}, $index, 0, @$entries;
}

sub add_entries_at {
    my( $self, $index, $entries ) = @_;

    $self->_add_entries_at( $index, $entries );
    $self->notify_subscribers( 'add_entries',
                               index => $index,
                               count => scalar @$entries,
                               );
}

sub _delete_entries {
    my( $self, $index, $count ) = @_;

    return splice @{$self->entries}, $index, $count;
}

sub delete_entry {
    my( $self, $index ) = @_;

    $self->_delete_entries( $index, 1 );
    $self->notify_subscribers( 'delete_entries',
                               index => $index,
                               count => 1,
                               );
}

sub move_entry {
    my( $self, $from, $to ) = @_;
    my( $entry ) = $self->_delete_entries( $from, 1 );
    $self->_add_entries_at( $to, [ $entry ] );
    $self->notify_subscribers( 'move_entries',
                               from  => $from,
                               to    => $to,
                               count => 1,
                               );
}

sub count    { scalar @{$_[0]->entries} }

sub _fixup_iterator {
    my( $self, $it, $event, %args ) = @_;

    if( $event eq 'add_entries' ) {
        if( $it->current >= $args{index} ) {
            $it->current( $it->current + $args{count} );
        }
    } elsif( $event eq 'delete_entries' ) {
        if( $it->current >= $args{index} ) {
            if( $it->current < $args{index} + $args{count} ) {
                $it->current( 0 );
            } else {
                $it->current( $it->current - $args{count} );
            }
        }
    } elsif( $event eq 'move_entries' ) {
        if(    $it->current >= $args{from}
            && $it->current < $args{from} + $args{count} ) {
            $it->current( $it->current - $args{from} + $args{to} );
        } else {
            $self->_fixup_iterator( $it, 'delete_entries',
                                    index => $args{from},
                                    count => $args{count},
                                    );
            $self->_fixup_iterator( $it, 'add_entries',
                                    index => $args{to},
                                    count => $args{count},
                                    );
        }
    }
}

1;
