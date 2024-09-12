#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::sbprovider;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('sbprovider');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx name firma vertrag kontakt1 kontakt2 land email www iskabprov refcount/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Set relationships:
####################

# has_many( refname => table, foreign ref to my PK ):
__PACKAGE__->has_many(sb_sbp => 'katamaDB::signalbezug', 'sbp_idx', { cascade_delete => 0 });
__PACKAGE__->has_many(kpf_sbp => 'katamaDB::kabelprogfreq', 'sbp_idx', { cascade_delete => 0 });

=head1 NAME

katamaDB::signalbezug

=head1 DESCRIPTION

=cut

1;
