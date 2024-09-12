#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::programm;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('programm');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx pg_type name genre land sprache teletext stereo hdtv dolbydig surround issched schedfrom schedto anmerkungen betreiber vertragsdaten www refcount/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Set relationships:
####################

# has_many( refname => table, foreign ref to my PK ):
__PACKAGE__->has_many(bp_pg => 'katamaDB::bouquetprogramm', 'pg_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(bp_pgbq => 'katamaDB::bouquetprogramm', 'pgbq_idx', { cascade_delete => 0 });

__PACKAGE__->has_many(spf_pg => 'katamaDB::satprogfreq', 'pg_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(kpf_pg => 'katamaDB::kabelprogfreq', 'pg_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(tpf_pg => 'katamaDB::terrprogfreq', 'pg_idx', { cascade_delete => 0 });

__PACKAGE__->has_many(kt_pg => 'katamaDB::kanaltabelle', 'pg_idx', { cascade_delete => 0 });

=head1 NAME

katamaDB::programm

=head1 DESCRIPTION

=cut

1;
