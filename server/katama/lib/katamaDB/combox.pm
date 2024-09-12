#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::combox;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('combox');
# Set columns in table
__PACKAGE__->add_columns(qw/cbname value abbr display1 display2/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/cbname value/);

=head1 NAME

katamaDB::sqsearch

=head1 DESCRIPTION

=cut

1;
