#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::signalbezug;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('signalbezug');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx sbp_idx sb_type kennung1 kennung2 sat_pos sat_eirp sat_beam sat_band sat_codx up_strasse up_hausnr up_hausnrzus up_plz up_ort up_issbprovkt refcount/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Set relationships:
####################

# has_many( refname => table, foreign ref to my PK ):
__PACKAGE__->has_many(sq_sb => 'katamaDB::signalquellensignal', 'sb_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(spf_sb => 'katamaDB::satprogfreq', 'sb_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(kpf_sb => 'katamaDB::kabelprogfreq', 'sb_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(tpf_sb => 'katamaDB::terrprogfreq', 'sb_idx', { cascade_delete => 0 });

# belongs_to( refname => table, my ref to foreign PK):
__PACKAGE__->belongs_to(b2_sbp => 'katamaDB::sbprovider', 'sbp_idx');

=head1 NAME

katamaDB::signalbezug

=head1 DESCRIPTION

=cut

1;
