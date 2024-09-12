#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::bouquetprogramm;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('bouquetprogramm');
# Set columns in table
__PACKAGE__->add_columns(qw/pgbq_idx pg_idx/);

# Set relationships:
####################

# belongs_to( refname => table, my ref to foreign PK):
__PACKAGE__->belongs_to(b2_pgbq => 'katamaDB::programm', 'pgbq_idx');
__PACKAGE__->belongs_to(b2_pg => 'katamaDB::programm', 'pg_idx');

=head1 NAME

katamaDB::bouquetprogramm

=head1 DESCRIPTION

=cut

1;
