#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::contactoffice;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('contactoffice');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx firma kontakt telefon fax strasse hausnr hausnrzus plz ort/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Set relationships:
####################

# has_many( refname => table, foreign ref to my PK ):
__PACKAGE__->has_many(sq_co => 'katamaDB::signalquelle', 'co_idx', { cascade_delete => 0 });


=head1 NAME

katamaDB::contactoffice

=head1 DESCRIPTION

=cut

1;
