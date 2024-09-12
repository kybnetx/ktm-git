#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1.  Stub - name of this controller
# 2.  STUB_TABLEABBR - table abbreviation for mapping functions
# 3.  STUB_TABLETYPE - table type discriminator, usualy like xx_type
# 3a. STTVAL - table type identifier (1, 2, etc)
# 4.  STUB_RESTMODEL - application DB model for REST interface
# 5.  STUB_RESTACTION - actions of REST interface
# 6.  STUB_ACTIONPATH - path to access actions of REST interface
#


package katama::Controller::Stub;

use strict;
use warnings;
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

	$c->response->body('Matched katama::Controller::Stub');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


sub set_STUB_TABLEABBR {
	my $row = shift;
	my %n;
		$n{'uidx'} = $row->{uidx} if (defined($row->{uidx}));
# ----------------------------------
#		$n{''} = $row->{} if (defined($row->{}));
	return \%n
}


sub get_STUB_TABLEABBR {
	my $row = shift;
	my %e = (
		uidx => $row->uidx,
# ----------------------------------
#		=> $row->,
	);
	return \%e
}


#########  STUB_RESTMODEL  #########

### ALL (no args) ###
sub STUB_RESTACTION_all : Path('/STUB_ACTIONPATH') : Args(0) : ActionClass('REST') {
	my ( $self, $c ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUB_RESTACTION_all [ $info ]");
#]]
}

# GET
sub STUB_RESTACTION_all_GET  {
	my ( $self, $c ) = @_;
	my ( $m, @rowobjs, $row, %data );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUB_RESTACTION_all_GET [ $info ]");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::STUB_RESTMODEL');

	# pickup all records
#	@rowobjs = $m->all();
	@rowobjs = $m->search( { 'STUB_TABLETYPE' => 'STTVAL' } );

	if ( ! @rowobjs ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# map result row into JSON data array
	$data{'STUB_TABLEABBR'} = ();
	for $row ( @rowobjs ) {
		# don't take dummy record which has uidx 0
		next if ($row->uidx == 0);
		push( @{ $data{'STUB_TABLEABBR'} }, get_STUB_TABLEABBR($row) );
	}

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

# POST - PAGING METHOD OF EXT
sub STUB_RESTACTION_all_POST {
	my ( $self, $c ) = @_;
	my ( $m, @rowobjs, $row, %data, $start, $limit, $rowscount );

	$start = $c->request->param('start');
	$limit = $c->request->param('limit');

	if( !defined($start) || !defined($limit) ) {
		return $self->status_bad_request( $c,
			message => "POST_pageidmissing" );
	}
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUB_RESTACTION_all_POST [ $info ]");
	$c->log->debug("###### /START: $start/ - /LIMIT: $limit/");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::STUB_RESTMODEL');

	# get the total row count of the dataset
	$rowscount = $m->count( 'STUB_TABLETYPE' => 'STTVAL' );

	# pickup requested records
	@rowobjs = $m->search( { 'STUB_TABLETYPE' => 'STTVAL' }, { 'rows' => $limit, 'page' => ($start/$limit + 1) } );

	if ( ! @rowobjs ) {
		return $self->status_not_found( $c,
			message => "POST_notfound" );
	}

	# map result row into JSON data array
	$data{'STUB_TABLEABBR'} = ();
	for $row ( @rowobjs ) {
		push( @{ $data{'STUB_TABLEABBR'} }, get_STUB_TABLEABBR($row) );
	}

	# the total number of rows for pager
	$data{'count'} = $rowscount;

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

### SINGLE ( arg1 == uidx ) or MULTI ( arg1 == 'm' ) ###
sub STUB_RESTACTION : Path('/STUB_ACTIONPATH') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $uidx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUB_RESTACTION /UIDX $uidx/ - [ $info ]");
#]]
}

# GET
sub STUB_RESTACTION_GET  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row, %data );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUB_RESTACTION_GET /UIDX $uidx/ - [ $info ]");
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

	# pickup the model for this controler
	$m = $c->model('katamaDB::STUB_RESTMODEL');

	# find record we are looking for
	$row = $m->find( $uidx );

#	if ( !defined($row) ) {
	if ( !defined($row) || $row->STUB_TABLETYPE != 'STTVAL' ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# map result row into JSON data array
	$data{'STUB_TABLEABBR'} = [ get_STUB_TABLEABBR($row) ];

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

# SINGLE POST
sub STUB_RESTACTION_POST  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row, $data, $rec );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUB_RESTACTION_POST /UIDX $uidx/ - [ $info ]");
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

	# UPDATE or CREATE for multiple rows ( /STUB_ACTIONPATH/m )
	if ( $uidx eq 'm' ) {
		return STUB_RESTACTION_multi_post( $self, $c, $data );
	}

	# hash index of data for particular table
	$data = $data->{'STUB_TABLEABBR'}[0];

#[[
	my $key;
	foreach $key ( keys %$data ) {
		$c->log->debug("RECEIVED Key $key => ".$data->{$key}) if (defined($data->{$key}));
	}
#]]

	# map received data to the table columns
	$rec = set_STUB_TABLEABBR($data);
	delete $rec->{guid} if(defined($rec->{guid}));

	# do adjustments for UPDATE
	if( $uidx ) {
	}
	# do adjustments for CREATE
	else {
		$rec->{STUB_TABLETYPE} = 'STTVAL'
	}

#[[
	foreach $key ( keys %$rec) {
		$c->log->debug("MAPPED DATA to Key $key => ".$rec->{$key});
	}
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::STUB_RESTMODEL');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		### UPDATE ########################
		if ( $uidx ) {

			# first find record to update
			$row = $m->find( $uidx );

#			if ( !defined($row) ) {
			if ( !defined($row) || $row->STUB_TABLETYPE != 'STTVAL' ) {
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
sub STUB_RESTACTION_DELETE  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUB_RESTACTION_DELETE /UIDX $uidx/ - [ $info ]");
#]]

	# don't process dummy record which has uidx 0
	if( $uidx == 0 ) {
		return $self->status_bad_request( $c,
			message => "DELETE_idbad" );
	}

	# pickup the model for this controler
	$m = $c->model('katamaDB::STUB_RESTMODEL');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {
		$row = $m->find($uidx);

#		if ( !defined($row) ) {
		if ( !defined($row) || $row->STUB_TABLETYPE != 'STTVAL' ) {
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
*STUB_RESTACTION_PUT = *STUB_RESTACTION_POST;

# MULTI POST
sub STUB_RESTACTION_multi_post {
	my ( $self, $c, $data ) = @_;
	my ( $m, @rowobjs, $row, @recobjs, $rec, $datarec, $uidx, $guid );

#[[
	$c->log->debug("###### DEBUGGE: STUB_RESTACTION_multi_post");
#]]

	# hash index of data for particular table
	$data = $data->{'STUB_TABLEABBR'};

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

		$rec = set_STUB_TABLEABBR($datarec);

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
			$rec->{STUB_TABLETYPE} = 'STTVAL';
		}

		push ( @recobjs, $rec );

#[[
		foreach $key ( keys %$rec) {
			$c->log->debug("MAPPED DATA to Key $key => ".$rec->{$key});
		}
#]]
	}

	# pickup the model for this controler
	$m = $c->model('katamaDB::STUB_RESTMODEL');

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

#				if ( !defined($row) ) {
				if ( !defined($row) || $row->STUB_TABLETYPE != 'STTVAL' ) {
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

# END #########  STUB_RESTMODEL  #########


1;
