#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::kabelprogfreq;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('kabelprogfreq');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx sbp_idx sb_idx pg_idx kf_idx sig_type bc_type iscryp/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Set relationships:
####################

# belongs_to( refname => table, my ref to foreign PK):
__PACKAGE__->belongs_to(b2_sb => 'katamaDB::signalbezug', 'sb_idx');
__PACKAGE__->belongs_to(b2_sbp => 'katamaDB::sbprovider', 'sbp_idx');
__PACKAGE__->belongs_to(b2_pg => 'katamaDB::programm', 'pg_idx');
__PACKAGE__->belongs_to(b2_kf => 'katamaDB::kanalfreq', 'kf_idx');

=head1 NAME

katamaDB::satprogfreq

=head1 DESCRIPTION

=cut

1;
