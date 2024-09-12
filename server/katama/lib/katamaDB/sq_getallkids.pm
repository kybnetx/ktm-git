#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::sq_getallkids;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('sq_getallkids');
# Set columns in table
__PACKAGE__->add_columns(qw/uidx tlevel tidx0 tidx1 tidx2 tidx3 ptemp co_idx sq_idx sumwe wesoll netzid sq_type dataorigin strasse hausnr hausnrzus plz ort land region/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uidx/);

# Create new ResultSource
#my $rsi = __PACKAGE__->result_source_instance();
#
## Read data from temporary table
#my $getallkids = $rsi->new( $rsi );
#$getallkids->source_name( 'GetAllKids' );
#$getallkids->name( \<<SQL );
#( SELECT * FROM sq_getallkids )
#SQL
#katamaDB->register_source( 'GetAllKids' => $getallkids );

=head1 NAME

katamaDB::sq_getallkids

=head1 DESCRIPTION

=cut

1;
