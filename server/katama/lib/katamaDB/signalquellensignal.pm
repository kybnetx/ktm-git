#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::signalquellensignal;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('signalquellensignal');
# Set columns in table
__PACKAGE__->add_columns(qw/sb_idx sq_idx/);

# Set relationships:
####################

# belongs_to( refname => table, my ref to foreign PK):
__PACKAGE__->belongs_to(b2_sb => 'katamaDB::signalbezug', 'sb_idx');
__PACKAGE__->belongs_to(b2_sq => 'katamaDB::signalquelle', 'sq_idx');

=head1 NAME

katamaDB::signalquellensignal

=head1 DESCRIPTION

=cut

1;
