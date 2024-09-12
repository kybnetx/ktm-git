#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::kanalfreq;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('kanalfreq');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx kanal freq1 freq2 middfreq bildtraeger isradio refcount/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Set relationships:
####################

# has_many( refname => table, foreign ref to my PK ):
__PACKAGE__->has_many(kpf_kf => 'katamaDB::kabelprogfreq', 'kf_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(sqf_kf => 'katamaDB::signalquellenfilter', 'kf_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(kt_kf => 'katamaDB::kanaltabelle', 'kf_idx', { cascade_delete => 0 });

=head1 NAME

katamaDB::programm

=head1 DESCRIPTION

=cut

1;
