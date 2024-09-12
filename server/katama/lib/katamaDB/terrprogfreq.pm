#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::terrprogfreq;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('terrprogfreq');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx sb_idx pg_idx freq sig_type bc_type iscryp/); # added: polar fec fft guard mod_type
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Set relationships:
####################

# belongs_to( refname => table, my ref to foreign PK):
__PACKAGE__->belongs_to(b2_sb => 'katamaDB::signalbezug', 'sb_idx');
__PACKAGE__->belongs_to(b2_pg => 'katamaDB::programm', 'pg_idx');

=head1 NAME

katamaDB::satprogfreq

=head1 DESCRIPTION

=cut

1;
