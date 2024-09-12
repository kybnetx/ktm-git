#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1. Programm - name of this controller
# 2. pg - table abbreviation for mapping functions
# 4. programm - application DB model for REST interface
# 5. pgext_grid - actions of REST interface
# 6. pgext - path to access actions of REST interface
#


package katama::Controller::Programm;

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

	$c->response->body('Matched katama::Controller::Programm');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


### mapping functions ###


sub set_pg {
	my $row = shift;
	my %n;
		$n{'uidx'} = $row->{uidx} if (defined($row->{uidx}));
# ----------------------------------
#		$n{'issched'} = ($row->{iss} eq 'true' ? 1 : 0 ) if (defined($row->{iss}));
		$n{'issched'} = $row->{iss} if (defined($row->{iss}));
		$n{'schedfrom'} = $row->{sfr} if (defined($row->{sfr}));
		$n{'schedto'} = $row->{sto} if (defined($row->{sto}));
		$n{'anmerkungen'} = $row->{anm} if (defined($row->{anm}));
		$n{'betreiber'} = $row->{btr} if (defined($row->{btr}));
		$n{'vertragsdaten'} = $row->{vtd} if (defined($row->{vtd}));
		$n{'www'} = $row->{www} if (defined($row->{www}));
# ----------------------------------
		$n{'guid'} = $row->{guid} if (defined($row->{guid}));
	return \%n;
}


sub get_pg {
	my $row = shift;
	my %e = (
		uidx => $row->uidx,
# ----------------------------------
		nam => $row->name,
		iss => $row->issched,
		sfr => $row->schedfrom,
		sto => $row->schedto,
		anm => $row->anmerkungen,
		btr => $row->betreiber,
		vtd => $row->vertragsdaten,
		www => $row->www
# ----------------------------------
	);
	$e{pgt} = katama::Common::get_pgtype($row->pg_type);
	return \%e;
}


### data selection ###

# programm selection for binding with bouquetprogramm and signalbezug

sub selectmodel_PGSEL_pg {
	my ( $self, $c, $cond, $pagesel ) = @_;
	my ( $m, @rowobjs, $row, %data );

	# pickup the model for this controler
	$m = $c->model('katamaDB::programm');

	my %nzpk = ( uidx => { '>', 0 } );
	$cond = \%nzpk if(!$cond);

	# pickup records
	if(!$pagesel) {
		@rowobjs = $m->search( $cond ) or return 0;
	}
	else {
		@rowobjs = $m->search( $cond, $pagesel ) or return 0;
	}

	# map result row into JSON data array
	$data{'pgsel'} = ();
	for $row ( @rowobjs ) {

		my %e = ();
		$e{'uidx'} = $row->uidx;
		$e{'pgt'} = katama::Common::get_pgtype($row->pg_type);
		$e{'nam'} = $row->name;
		$e{'gnr'} = $row->genre;

		push( @{ $data{'pgsel'} }, \%e );
	}

	if($pagesel) {
		# get the total row count of the dataset
		my $rowscount = $m->count( $cond );
		$data{'count'} = $rowscount;
	}

	return \%data;
}


# main programm table maintainance

sub selectmodel_MAIN_pg {
	my ( $self, $c, $cond, $pagesel ) = @_;
	my ( $m, @rowobjs, $row, %data );

	# pickup the model for this controler
	$m = $c->model('katamaDB::programm');

	my %nzpk = ( uidx => { '>', 0 } );
	$cond = \%nzpk if(!$cond);

	# pickup records
	if(!$pagesel) {
		@rowobjs = $m->search( $cond ) or return 0;
	}
	else {
		@rowobjs = $m->search( $cond, $pagesel ) or return 0;
	}

	# map result row into JSON data array
	$data{'pg'} = ();
	for $row ( @rowobjs ) {

		# call basic mapper
		push( @{ $data{'pg'} }, get_pg($row) );
	}

	if($pagesel) {
		# get the total row count of the dataset
		my $rowscount = $m->count( $cond );
		$data{'count'} = $rowscount;
	}

	return \%data;
}


###### REST service  ######

### ALL (no args) ###
sub pgext_grid_all : Path('/pgext') : Args(0) : ActionClass('REST') {
	my ( $self, $c ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_all [ $info ]");
#]]
}

# GET
sub pgext_grid_all_GET  {
	my ( $self, $c ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_all_GET [ $info ]");
#]]

	my $data = selectmodel_MAIN_pg( $self, $c, undef, undef );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# POST - PAGING METHOD OF EXT
sub pgext_grid_all_POST {
	my ( $self, $c ) = @_;
	my ( $m, @rowobjs, $row );

	my $start = $c->request->param('start');
	my $limit = $c->request->param('limit');

	if( !defined($start) || !defined($limit) ) {
		return $self->status_bad_request( $c,
			message => "POST_pageidmissing" );
	}
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_all_POST [ $info ]");
	$c->log->debug("###### /START: $start/ - /LIMIT: $limit/");
#]]

	my $data = selectmodel_MAIN_pg( $self, $c, undef, { 'rows' => $limit, 'page' => ($start/$limit + 1) } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "POST_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

###############################################################################

### PROGRAMM SELECTION FOR BOUQUET ###
sub pgext_grid_bqsel : Path('/pgext_bqsel') : Args(0) : ActionClass('REST') {
	my ( $self, $c ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_bqsel [ $info ]");
#]]
}

# GET
sub pgext_grid_bqsel_GET  {
	my ( $self, $c ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_bqsel_GET [ $info ]");
#]]

	my $data = selectmodel_PGSEL_pg( $self, $c, { '-or' => [ pg_type => 1, pg_type => 2 ] }, undef );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# POST
sub pgext_grid_bqsel_POST  {
	my ( $self, $c ) = @_;

	my $start = $c->request->param('start');
	my $limit = $c->request->param('limit');

	if( !defined($start) || !defined($limit) ) {
		return $self->status_bad_request( $c,
			message => "POST_pageidmissing" );
	}
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_bqsel_POST [ $info ]");
	$c->log->debug("###### /START: $start/ - /LIMIT: $limit/");
#]]

	my $data = selectmodel_PGSEL_pg( $self, $c, { '-or' => [ pg_type => 1, pg_type => 2 ] }, { 'rows' => $limit, 'page' => ($start/$limit + 1) } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "POST_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

###############################################################################

### PROGRAMM SELECTION FOR SIGNALBEZUG ###
sub pgext_grid_sel : Path('/pgext_sel') : Args(0) : ActionClass('REST') {
	my ( $self, $c ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_sel [ $info ]");
#]]
}

# GET
sub pgext_grid_sel_GET  {
	my ( $self, $c ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_sel_GET [ $info ]");
#]]

	my $data = selectmodel_PGSEL_pg( $self, $c, undef, undef );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# POST
sub pgext_grid_sel_POST  {
	my ( $self, $c ) = @_;

	my $start = $c->request->param('start');
	my $limit = $c->request->param('limit');

	if( !defined($start) || !defined($limit) ) {
		return $self->status_bad_request( $c,
			message => "POST_pageidmissing" );
	}
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_sel_POST [ $info ]");
	$c->log->debug("###### /START: $start/ - /LIMIT: $limit/");
#]]

	my $data = selectmodel_PGSEL_pg( $self, $c, undef, { 'rows' => $limit, 'page' => ($start/$limit + 1) } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "POST_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

###############################################################################

### SINGLE ( arg1 == uidx ) or MULTI ( arg1 == 'm' ) ###
sub pgext_grid : Path('/pgext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $uidx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid /UIDX $uidx/ - [ $info ]");
#]]
}

# GET
sub pgext_grid_GET  {
	my ( $self, $c, $uidx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_GET /UIDX $uidx/ - [ $info ]");
#]]

	if( !defined($uidx) ) {
		return $self->status_bad_request( $c,
			message => "GET_idmissing" );
	}

	# don't process dummy record which has uidx 0
	if( $uidx == 0 ) {
		return $self->status_bad_request( $c,
			message => "GET_idbad" );
	}

	my $data = selectmodel_MAIN_pg( $self, $c, { 'me.uidx' => $uidx }, undef );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# SINGLE POST
sub pgext_grid_POST  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row, $data, $rec );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_POST /UIDX $uidx/ - [ $info ]");
#]]

	# don't process dummy record which has uidx 0
	if( $uidx ne 'm' && $uidx == 0 ) {
		return $self->status_bad_request( $c,
			message => "POST_idbad" );
	}

	# get data from the request body
	$data = $c->req->data;

	if (!defined($data)) {
		return $self->status_bad_request( $c,
			message => "POST_datamissing" );
	}

	# UPDATE or CREATE for multiple rows ( /pgext/m )
	if ( $uidx eq 'm' ) {
		return pgext_grid_multi_post( $self, $c, $data );
	}

	# hash index of data for particular table
	$data = $data->{'pg'}[0];

#[[
	my $key;
	foreach $key ( keys %$data ) {
		$c->log->debug("RECEIVED Key $key => ".$data->{$key}) if (defined($data->{$key}));
	}
#]]

	# map received data to the table columns
	$rec = set_pg($data);
	delete $rec->{guid} if(defined($rec->{guid}));

	# do adjustments for UPDATE
	if( $uidx ) {
	}
	# do adjustments for CREATE
	else {
	}

#[[
	foreach $key ( keys %$rec) {
		$c->log->debug("MAPPED DATA to Key $key => ".$rec->{$key});
	}
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::programm');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		### UPDATE ########################
		if ( $uidx ) {

			# first find record to update
			$row = $m->find( $uidx );

			if ( !defined($row) ) {
				katama::Common::unlock_app($c);
				return $self->status_not_found( $c,
					message => "POST_notfound" );
			}

			# update record with the fresh data
			$row->update( $rec );

			katama::Common::unlock_app($c);

#[[
			$c->log->debug("UPDATE uidx: $uidx - row: ".$row);
#]]

			# status_ok
			return $self->status_ok( $c,
				entity => { uidx => $uidx } );
		}

		### CREATE ########################
		else {

			# create a brand new record with received data
			$row = $m->create( $rec );

			# find out the index of new record
			$uidx = $row->uidx;

			katama::Common::unlock_app($c);

#[[
			$c->log->debug("CREATE uidx: $uidx - row: ".$row);
#]]

			# status created
			return $self->status_created( $c,
				location => $c->req->uri->as_string,
				entity => { uidx => $uidx } );
		}
	}

	# HANDLE LOCK ERROR HERE
	else {
		return $self->status_not_found( $c,
			message => "POST_cannotlock" );
	}

	# never reached
}

# DELETE
sub pgext_grid_DELETE  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: pgext_grid_DELETE /UIDX $uidx/ - [ $info ]");
#]]

	# don't process dummy record which has uidx 0
	if( $uidx == 0 ) {
		return $self->status_bad_request( $c,
			message => "DELETE_idbad" );
	}

	# pickup the model for this controler
	$m = $c->model('katamaDB::programm');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {
		$row = $m->find($uidx);

		if ( !defined($row) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "DELETE_notfound" );
		}

		if ( $row->refcount ) {
			katama::Common::unlock_app($c);
			return $self->status_bad_request( $c,
				message => "DELETE_refcount,".$row->refcount );
		}

		$row->delete;

		katama::Common::unlock_app($c);

#[[
		$c->log->debug("DELETE uidx: $uidx - row: ".$row);
#]]

		return $self->status_ok( $c,
			entity => { uidx => $row->uidx } );
	}

	# HANDLE LOCK ERROR HERE
	else {
		return $self->status_not_found( $c,
			message => "DELETE_cannotlock" );
	}

	# never reached
}

# we don't use PUT
*pgext_grid_PUT = *pgext_grid_POST;

###############################################################################

# MULTI POST
sub pgext_grid_multi_post {
	my ( $self, $c, $data ) = @_;
	my ( $m, @rowobjs, $row, @recobjs, $rec, $datarec, $uidx, $guid );

#[[
	$c->log->debug("###### DEBUGGE: pgext_grid_multi_post");
#]]

	# hash index of data for particular table
	$data = $data->{'pg'};

	# map received data to the table columns
	@recobjs = ();
	for $datarec ( @$data ) {

#[[
		my $key;
		$c->log->debug("\n--- DATARECORD ---");
		foreach $key ( keys %$datarec ) {
			$c->log->debug("RECEIVED Key $key => ".$datarec->{$key}) if (defined($datarec->{$key}));
		}
#]]

		$rec = set_pg($datarec);

		# do adjustments for UPDATE
		if( defined($rec->{uidx}) ) {
			delete $rec->{guid} if(defined($rec->{guid}));
		}
		# do adjustments for CREATE
		else {
			if ( !defined( $rec->{guid} ) ) {
				return $self->status_bad_request( $c,
					message => "POST_guidmissing" );
			}
		}

		push ( @recobjs, $rec );

#[[
		foreach $key ( keys %$rec) {
			$c->log->debug("MAPPED DATA to Key $key => ".$rec->{$key});
		}
#]]
	}

	# pickup the model for this controler
	$m = $c->model('katamaDB::programm');

	# return hash of rows for status 'UPD', 'ERR' and 'NEW'
	my %ret = ();

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		for $rec ( @recobjs ) {

			### UPDATE ########################
			if ( defined($rec->{uidx}) ) {

				$uidx = $rec->{uidx};

				# first find record to update
				$row = $m->find( $uidx );

				if ( !defined($row) ) {
					# return hash ERROR status
					push( @{ $ret{'ERR'} }, { uidx => $uidx } );
					next; 
				}

				# update record with the fresh data
				$row->update( $rec );

#[[
				$c->log->debug("UPDATE uidx: $uidx - row: ".$row);
#]]

				# return hash UPDATE status
				push( @{ $ret{'UPD'} }, { uidx => $uidx } );
			}

			### CREATE ########################
			else {

				# pickup GUI guid and remove from DB record
				$guid = $rec->{guid};
				delete $rec->{guid};

				# create a brand new record with received data
				$row = $m->create( $rec );

				# find out the index of new record
				$uidx = $row->uidx;

#[[
				$c->log->debug("CREATE uidx: $uidx - row: ".$row);
#]]

				# return hash CREATE status
				# new records uidx must be mapped with GUI guid to identify them
				push( @{ $ret{'NEW'} }, { uidx => $uidx, guid => $guid } );
			}
		}

		katama::Common::unlock_app($c);

		# status_ok
		return $self->status_ok( $c,
			entity => \%ret );
	}

	# HANDLE LOCK ERROR HERE
	else {
		return $self->status_not_found( $c,
			message => "POST_cannotlock" );
	}

	# never reached
}

# END #


1;
