#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katamaDB::rawsql;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/Core/);
# Set the table name
__PACKAGE__->table('dummy');
# Set columns in table
__PACKAGE__->add_columns(qw/ret/);

# Create new ResultSource
my $rsi = __PACKAGE__->result_source_instance();

### For locking
my $getlock = $rsi->new( $rsi );
$getlock->source_name( 'GetLock' );
$getlock->name( \<<SQL );
( SELECT GET_LOCK( 'catalyst' , ? ) AS ret )
SQL
katamaDB->register_source( 'GetLock' => $getlock );

### For un-locking
my $unlock = $rsi->new( $rsi );
$unlock->source_name( 'UnLock' );
$unlock->name( \<<SQL );
( SELECT RELEASE_LOCK( 'catalyst' ) AS ret )
SQL
katamaDB->register_source( 'UnLock' => $unlock );

### Generate temporary kids table
### Returns number of kids found
my $getallkids = $rsi->new( $rsi );
$getallkids->source_name( 'preGetAllKids' );
$getallkids->name( \<<SQL );
( SELECT sq_getallkids( ? ) AS ret )
SQL
katamaDB->register_source( 'preGetAllKids' => $getallkids );

=head1 NAME

katamaDB::rawsql

=head1 DESCRIPTION

=cut

1;
