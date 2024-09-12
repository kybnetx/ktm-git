#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1. Bouquetprogramm - name of this controller
# 2. bqpg - table abbreviation for mapping functions
# 4. bouquetprogramm - application DB model for REST interface
# 5. bqpgext_grid - actions of REST interface
# 6. bqpgext - path to access actions of REST interface
#


package katama::Controller::Bouquetprogramm;

use strict;
use warnings;
use Switch;
use katama::Common;

use base 'Catalyst::Controller::REST';

__PACKAGE__->config(
	'default' => 'text/x-json',
	'map' => {
		'text/xml' => 'JSONXS',
		'text/x-json' => 'JSONXS',
		'application/x-www-form-urlencoded' => 'JSONXS'
	}
);

=head1 NAME

=head1 DESCRIPTION

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	$c->response->body('Matched katama::Controller::Bouquetprogramm');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


### data selection ###

# returns JSON array for table generation
sub selectmodel_PROGRAMM_bqpg_a {
	my ( $self, $c, $cond, $table ) = @_;
	my ( $m, @rowobjs, $row );

	# pickup the model for this controler
	$m = $c->model('katamaDB::bouquetprogramm');

	# pickup records
	@rowobjs = $m->search(
		$cond,
		{
			# belongs_to relations to create join
			join => [ 'b2_pg' ],
			'+select' => [ qw/ b2_pg.pg_type b2_pg.name b2_pg.genre / ],
			'+as' => [ qw/ pgtype pgname pggenre / ]
		}
	) or return 0;

	my @data = ( ['Typ', 'Name', 'Genre'] );

	for $row ( @rowobjs ) {
		push( @data, [
			katama::Common::get_pgtype($row->get_column('pgtype')),
			$row->get_column('pgname'),
			$row->get_column('pggenre')
		]);
	}

	return (\@data);
}


# returns JSON hashish for Ext JsonStore
sub selectmodel_PROGRAMM_bqpg_h {
	my ( $self, $c, $cond, $table ) = @_;
	my ( $m, @rowobjs, $row );

	# pickup the model for this controler
	$m = $c->model('katamaDB::bouquetprogramm');

	# pickup records
	@rowobjs = $m->search(
		$cond,
		{
			# belongs_to relations to create join
			join => [ 'b2_pg' ],
			'+select' => [ qw/ b2_pg.pg_type b2_pg.name b2_pg.genre / ],
			'+as' => [ qw/ pgtype pgname pggenre / ]
		}
	) or return 0;

	my %data = ();

	for $row ( @rowobjs ) {
		push( @{ $data{'bqpg'} }, {
			pgid => $row->pg_idx,
			bqid => $row->pgbq_idx,
			pgt => katama::Common::get_pgtype($row->get_column('pgtype')),
			nam => $row->get_column('pgname'),
			gnr => $row->get_column('pggenre')
		});
#[[
		$c->log->debug("get_pgtype ".$row->get_column('pgtype'));
#]]
	}

	return (\%data);
}


###### REST service  ######

### ALL ( arg1 == pgbq_idx ) ###
sub bqpgext_grid_all : Path('/bqpgext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $pgbq_idx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: bqpgext_grid_all /pgbq_idx $pgbq_idx/ [ $info ]");
#]]
}

# GET
sub bqpgext_grid_all_GET  {
	my ( $self, $c, $pgbq_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: bqpgext_grid_all_GET /pgbq_idx $pgbq_idx/ [ $info ]");
#]]

	my $data = selectmodel_PROGRAMM_bqpg_h( $self, $c, { 'me.pgbq_idx' => $pgbq_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

### ALL TABLE ( arg1 == pgbq_idx ) ###
sub bqpgext_grid_table : Path('/bqpgext_tab') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $pgbq_idx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: bqpgext_grid_table /pgbq_idx $pgbq_idx/ [ $info ]");
#]]
}

# GET
sub bqpgext_grid_table_GET  {
	my ( $self, $c, $pgbq_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: bqpgext_grid_table_GET /pgbq_idx $pgbq_idx/ [ $info ]");
#]]

	my $data = selectmodel_PROGRAMM_bqpg_a( $self, $c, { 'me.pgbq_idx' => $pgbq_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data );
}

### SINGLE ( arg1 == pgbq_idx, arg2 == pg_idx ) ###
sub bqpgext_grid : Path('/bqpgext') : Args(2) : ActionClass('REST') {
	my ( $self, $c, $pgbq_idx, $pg_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: bqpgext_grid /pgbq_idx $pgbq_idx, pg_idx $pg_idx/ - [ $info ]");
#]]
}

# GET
sub bqpgext_grid_GET  {
	my ( $self, $c, $pgbq_idx, $pg_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: bqpgext_grid_GET /pgbq_idx $pgbq_idx, pg_idx $pg_idx/ - [ $info ]");
#]]

	my ( $data, $t ) = selectmodel_PROGRAMM_bqpg_h( $self, $c, { 'me.pgbq_idx'=>$pgbq_idx, 'me.pg_idx'=>$pg_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# POST
sub bqpgext_grid_POST  {
	my ( $self, $c, $pgbq_idx, $pg_idx ) = @_;
	my ( $m, $mbq, $mpg, $row, %rec );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: bqpgext_grid_POST /pgbq_idx $pgbq_idx, pg_idx $pg_idx/ - [ $info ]");
#]]

	# map received data to the table columns
	$rec{'pgbq_idx'} = $pgbq_idx;
	$rec{'pg_idx'} = $pg_idx;

	# pickup the model for this controler
	$m = $c->model('katamaDB::bouquetprogramm');
	$mpg = $c->model('katamaDB::programm');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		### CREATE ########################

		# check here for the existence of the keys in related tables
		$row = $mpg->find($pgbq_idx);

		if ( !defined($row) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "POST_relnotfound" );
		}

		$row = $mpg->find($pg_idx);

		if ( !defined($row) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "POST_relnotfound" );
		}

		# check here for duplicates
		if ( defined( $m->search( { 'me.pgbq_idx' => $pgbq_idx, 'me.pg_idx' => $pg_idx } )->next ) ) {
			katama::Common::unlock_app($c);
			return $self->status_bad_request( $c,
				message => "POST_duplicate" );
		}

		# create a brand new record with received data
		$row = $m->create( \%rec );

		katama::Common::unlock_app($c);

#[[
		$c->log->debug("CREATED!");
#]]

		# status created
		return $self->status_created( $c,
			location => $c->req->uri->as_string,
			entity => { pgbqid => $pgbq_idx, pgid => $pg_idx } );
	}

	# HANDLE LOCK ERROR HERE
	else {
		return $self->status_not_found( $c,
			message => "POST_cannotlock" );
	}

	# never reached
}

# DELETE
sub bqpgext_grid_DELETE  {
	my ( $self, $c, $pgbq_idx, $pg_idx ) = @_;
	my ( $m, $rs );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: bqpgext_grid_DELETE /pgbq_idx $pgbq_idx, pg_idx $pg_idx/ - [ $info ]");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::bouquetprogramm');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		$rs = $m->search( { 'me.pgbq_idx' => $pgbq_idx, 'me.pg_idx' => $pg_idx } );

		if ( !defined($rs->next) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "DELETE_notfound" );
		}

		$rs->delete;

		katama::Common::unlock_app($c);

#[[
		$c->log->debug("DELETED!");
#]]
		return $self->status_ok( $c,
			entity => { bqid => $pgbq_idx, pgid => $pg_idx } );
	}

	# HANDLE LOCK ERROR HERE
	else {
		return $self->status_not_found( $c,
			message => "DELETE_cannotlock" );
	}

	# never reached
}

# we don't use PUT
*bqpgext_grid_PUT = *bqpgext_grid_POST;

# END #

1;
