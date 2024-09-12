#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB;

=head1 NAME 

katamaDB

=cut

# Our schema needs to inherit from 'DBIx::Class::Schema'
use base qw/DBIx::Class::Schema/;

# load from a directory of the same name as schema class
#__PACKAGE__->load_classes(qw/Book BookAuthor Author/);

# load all from a directory of the same name as schema class
__PACKAGE__->load_classes(qw//);

# load from multiple namespaces.
#__PACKAGE__->load_classes({
#	katamaDB => [qw//]
#});

1;
