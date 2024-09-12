#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::kanaltabelle;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('kanaltabelle');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx kf_idx pg_idx sq_idx sb_idx inactive/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Set relationships:
####################

# belongs_to( refname => table, my ref to foreign PK):
__PACKAGE__->belongs_to(b2_kf => 'katamaDB::kanalfreq', 'kf_idx');
__PACKAGE__->belongs_to(b2_pg => 'katamaDB::programm', 'pg_idx');
__PACKAGE__->belongs_to(b2_sb => 'katamaDB::signalbezug', 'sb_idx');

# has_many( refname => table, foreign ref to my PK ):
__PACKAGE__->has_many(sq_kt => 'katamaDB::signalquellenkanal', 'sq_idx', { cascade_delete => 0 });

=head1 NAME

katamaDB::kanaltabelle

=head1 DESCRIPTION

=cut

1;
