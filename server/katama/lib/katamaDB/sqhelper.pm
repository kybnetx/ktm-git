#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::sqhelper;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('sqhelper');
# Set columns in table
__PACKAGE__->add_columns(qw/sq_idx count/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/sq_idx/);

# Set relationships:
####################

# belongs_to( refname => table, my ref to foreign PK):
__PACKAGE__->belongs_to(b2_sq => 'katamaDB::signalquelle', 'sq_idx');


=head1 NAME

katamaDB::sqhelper

=head1 DESCRIPTION

=cut

1;
