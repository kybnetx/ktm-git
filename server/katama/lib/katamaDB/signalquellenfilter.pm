#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::signalquellenfilter;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('signalquellenfilter');
# Set columns in table
__PACKAGE__->add_columns(qw/kf_idx sq_idx kf_self kf_cascade/);

# Set relationships:
####################

# belongs_to( refname => table, my ref to foreign PK):
__PACKAGE__->belongs_to(b2_kf => 'katamaDB::kanalfreq', 'kf_idx');
__PACKAGE__->belongs_to(b2_sq => 'katamaDB::signalquelle', 'sq_idx');

=head1 NAME

katamaDB::signalquellenfilter

=head1 DESCRIPTION

=cut

1;
