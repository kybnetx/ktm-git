#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::signalquelle;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('signalquelle');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx tlevel tidx0 tidx1 tidx2 tidx3 ptemp co_idx sq_idx sumwe wesoll netzid sq_type dataorigin strasse hausnr hausnrzus plz ort land region/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Set relationships:
####################

# has_many( refname => table, foreign ref to my PK ):
__PACKAGE__->has_many(sq_sq => 'katamaDB::signalquelle', 'sq_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(kt_sq => 'katamaDB::signalquellenkanal', 'sq_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(sb_sq => 'katamaDB::signalquellensignal', 'sq_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(sqf_sq => 'katamaDB::signalquellenfilter', 'sq_idx', { cascade_delete => 0 });

# has one ( refname => table )
__PACKAGE__->has_one(sqh_sq => 'katamaDB::sqhelper', undef, { cascade_delete => 0 });
__PACKAGE__->has_one(sqs_sq => 'katamaDB::sqsearch', undef, { cascade_delete => 0 });

# belongs_to( refname => table, my ref to foreign PK):
__PACKAGE__->belongs_to(b2_co => 'katamaDB::contactoffice', 'co_idx');
__PACKAGE__->belongs_to(b2_sq => 'katamaDB::signalquelle', 'sq_idx');


=head1 NAME

katamaDB::signalquelle

=head1 DESCRIPTION

=cut

1;
