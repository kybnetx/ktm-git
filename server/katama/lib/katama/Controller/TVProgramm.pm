#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 0. pg_type = 1
# 1. TVProgramm - name of this controller
# 2. tvp - table abbreviation for mapping functions
# 4. programm - application DB model for REST interface
# 5. tvpext_grid - actions of REST interface
# 6. tvpext - path to access actions of REST interface
#


package katama::Controller::TVProgramm;

use strict;
use warnings;
use katama::Common;
use Encode;

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

	$c->response->body('Matched katama::Controller::TVProgramm');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


sub set_tvp {
	my $row = shift;
	my %n;
		$n{'uidx'} = $row->{uidx} if (defined($row->{uidx}));
# ----------------------------------
		$n{'name'} = $row->{nam} if (defined($row->{nam}));
		$n{'genre'} = $row->{gnr} if (defined($row->{gnr}));
		$n{'land'} = $row->{lnd} if (defined($row->{lnd}));
		$n{'sprache'} = $row->{spr} if (defined($row->{spr}));
		$n{'teletext'} = $row->{ttt} if (defined($row->{ttt}));
		$n{'surround'} = $row->{sur} if (defined($row->{sur}));
		$n{'stereo'} = $row->{str} if (defined($row->{str}));
		$n{'hdtv'} = $row->{hdt} if (defined($row->{hdt}));
		$n{'dolbydig'} = $row->{ddg} if (defined($row->{ddg}));
# ----------------------------------
		$n{'guid'} = $row->{guid} if (defined($row->{guid}));
	return \%n
}


sub get_tvp {
	my $row = shift;
	my %e = (
		uidx => $row->uidx,
# ----------------------------------
		nam => $row->name,
		gnr => $row->genre,
		lnd => $row->land,
		spr => $row->sprache,
		ttt => $row->teletext,
		sur => $row->surround,
		str => $row->stereo,
		hdt => $row->hdtv,
		ddg => $row->dolbydig
	);
	return \%e;
}


#########  TVProgramm Controller  #########

### ALL (no args) ###
sub tvpext_grid_all : Path('/tvpext') : Args(0) : ActionClass('REST') {
	my ( $self, $c ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: tvpext_grid_all [ $info ]");
#]]
}

# GET
sub tvpext_grid_all_GET {
	my ( $self, $c ) = @_;
	my ( $m, @rowobjs, $row, %data );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: tvpext_grid_all_GET [ $info ]");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::programm');

	# pickup all records
	@rowobjs = $m->search( { 'pg_type' => 1 } );

	if ( ! @rowobjs ) {
		return $self->status_not_found( $c,
			message => "POST_notfound" );
	}

	# map result row into JSON data array
	$data{'tvp'} = ();
	for $row ( @rowobjs ) {
		push( @{ $data{'tvp'} }, get_tvp($row) );
	}

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

# POST - PAGING METHOD OF EXT
sub tvpext_grid_all_POST {
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
	$c->log->debug("###### DEBUGGE: tvpext_grid_all_POST [ $info ]");
	$c->log->debug("###### /START: $start/ - /LIMIT: $limit/");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::programm');

	# get the total row count of the dataset
	$rowscount = $m->count( 'pg_type' => 1 );

	# pickup requested records
	@rowobjs = $m->search( { 'pg_type' => 1 }, { 'rows' => $limit, 'page' => ($start/$limit + 1) } );

	if ( ! @rowobjs ) {
		return $self->status_not_found( $c,
			message => "POST_notfound" );
	}

	# map result row into JSON data array
	$data{'tvp'} = ();
	for $row ( @rowobjs ) {
		push( @{ $data{'tvp'} }, get_tvp($row) );
	}

	# the total number of rows for pager
	$data{'count'} = $rowscount;

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

#######################################

### SINGLE ( arg1 == uidx ) or MULTI ( arg1 == 'm' ) ###
sub tvpext_grid : Path('/tvpext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $uidx ) = @_;
#[[
	my $info = $c->request->content_type;
#]]
	if ( $uidx eq 'p' ) {
#[[
		$c->log->debug("###### DEBUGGE: forwarding to /tvpext/p/0");
#]]
		$c->forward('/tvprogramm/tvpext_grid_page', ['0']);
		$c->detach();
	}
#[[
	$c->log->debug("###### DEBUGGE: tvpext_grid /UIDX $uidx/ - [ $info ]");
#]]
}

# GET
sub tvpext_grid_GET  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row, %data );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: tvpext_grid_GET /UIDX $uidx/ - [ $info ]");
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
	$m = $c->model('katamaDB::programm');

	# find record we are looking for
	$row = $m->find( $uidx );

	if ( !defined($row) || $row->pg_type != 1 ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# map result row into JSON data array
	$data{'tvp'} = [ get_tvp($row) ];

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

# SINGLE POST
sub tvpext_grid_POST  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row, $data, $rec );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: tvpext_grid_POST /UIDX $uidx/ - [ $info ]");
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

	# UPDATE or CREATE for multiple rows ( /tvpext/m )
	if ( $uidx eq 'm' ) {
		return tvpext_grid_multi_post( $self, $c, $data );
	}

	# hash index of data for particular table
	$data = $data->{'tvp'}[0];

#[[
	my $key;
	foreach $key ( keys %$data ) {
		$c->log->debug("RECEIVED Key $key => ".$data->{$key}) if (defined($data->{$key}));
	}
#]]

	# map received data to the table columns
	$rec = set_tvp($data);
	delete $rec->{guid} if(defined($rec->{guid}));

	# do adjustments for UPDATE
	if( $uidx ) {
	}
	# do adjustments for CREATE
	else {
		$rec->{pg_type} = 1;
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

			if ( !defined($row) || $row->pg_type != 1 ) {
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
sub tvpext_grid_DELETE  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: tvpext_grid_DELETE /UIDX $uidx/ - [ $info ]");
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

		if ( !defined($row) || $row->pg_type != 1 ) {
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
*tvpext_grid_PUT = *tvpext_grid_POST;

#######################################

# MULTI POST
sub tvpext_grid_multi_post {
	my ( $self, $c, $data ) = @_;
	my ( $m, @rowobjs, $row, @recobjs, $rec, $datarec, $uidx, $guid );

#[[
	$c->log->debug("###### DEBUGGE: tvpext_grid_multi_post");
#]]

	# hash index of data for particular table
	$data = $data->{'tvp'};

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

		$rec = set_tvp($datarec);

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
			$rec->{pg_type} = 1;
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

				if ( !defined($row) || $row->pg_type != 1 ) {
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

# END #########  TVProgramm Controller  #########


1;
