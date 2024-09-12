#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1.  Satellit - name of this controller
# 2.  sat - table abbreviation for mapping functions
# 3.  sb_type - table type discriminator, usualy like xx_type
# 3a. 1 - table type identifier (1, 2, etc)
# 4.  signalbezug - application DB model for REST interface
# 5.  satext_grid - actions of REST interface
# 6.  satext - path to access actions of REST interface
#


package katama::Controller::Satellit;

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

	$c->response->body('Matched katama::Controller::Satellit');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


sub set_sat {
	my $row = shift;
	my %n;
		$n{'uidx'} = $row->{uidx} if (defined($row->{uidx}));
# ----------------------------------
		$n{'sbp_idx'} = $row->{sbpid} if (defined($row->{sbpid}));
		$n{'kennung1'} = $row->{kn1} if (defined($row->{kn1}));
		$n{'kennung2'} = $row->{kn2} if (defined($row->{kn2}));
		$n{'sat_pos'} = $row->{spo} if (defined($row->{spo}));
		$n{'sat_eirp'} = $row->{sei} if (defined($row->{sei}));
		$n{'sat_beam'} = $row->{sbe} if (defined($row->{sbe}));
		$n{'sat_band'} = $row->{sba} if (defined($row->{sba}));
		$n{'sat_codx'} = $row->{scx} if (defined($row->{scx}));
# ----------------------------------
		$n{'guid'} = $row->{guid} if (defined($row->{guid}));
	return \%n
}


sub get_sat {
	my $row = shift;
	my %e = (
		uidx => $row->uidx,
# ----------------------------------
		sbpid => $row->sbp_idx,
		kn1 => $row->kennung1,
		kn2 => $row->kennung2,
		spo => $row->sat_pos,
		sei => $row->sat_eirp,
		sbe => $row->sat_beam,
		sba => $row->sat_band,
		scx => $row->sat_codx,
	);
	return \%e
}


#########  signalbezug  #########

### ALL (no args) ###
sub satext_grid_all : Path('/satext') : Args(0) : ActionClass('REST') {
	my ( $self, $c ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satext_grid_all [ $info ]");
#]]
}

# GET
sub satext_grid_all_GET  {
	my ( $self, $c ) = @_;
	my ( $m, @rowobjs, $row, %data );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satext_grid_all_GET [ $info ]");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::signalbezug');

	# pickup all records
	@rowobjs = $m->search( { 'sb_type' => 1 }, { join => [ 'b2_sbp' ], '+select' => [ qw/ b2_sbp.name b2_sbp.firma b2_sbp.land / ], '+as' => [ qw/ sbpname sbpfirma sbpland / ] } );

	if ( ! @rowobjs ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	my $satmap;

	# map result row into JSON data array
	$data{'sat'} = ();
	for $row ( @rowobjs ) {
		# don't take dummy record which has uidx 0
		# next if ($row->uidx == 0);
		$satmap = get_sat($row);
		$satmap->{pnam} = $row->get_column('sbpname');
		$satmap->{pfrm} = $row->get_column('sbpfirma');
		$satmap->{plnd} = $row->get_column('sbpland');
		push( @{ $data{'sat'} }, $satmap );
	}

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

# POST - PAGING METHOD OF EXT
sub satext_grid_all_POST {
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
	$c->log->debug("###### DEBUGGE: satext_grid_all_POST [ $info ]");
	$c->log->debug("###### /START: $start/ - /LIMIT: $limit/");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::signalbezug');

	# get the total row count of the dataset
	$rowscount = $m->count( 'sb_type' => 1 );

	# pickup requested records
	@rowobjs = $m->search( { 'sb_type' => 1 }, { join => [ 'b2_sbp' ], '+select' => [ qw/ b2_sbp.name b2_sbp.firma b2_sbp.land / ], '+as' => [ qw/ sbpname sbpfirma sbpland / ], 'rows' => $limit, 'page' => ($start/$limit + 1) } );

	if ( ! @rowobjs ) {
		return $self->status_not_found( $c,
			message => "POST_notfound" );
	}

	my $satmap;

	# map result row into JSON data array
	$data{'sat'} = ();
	for $row ( @rowobjs ) {
		$satmap = get_sat($row);
		$satmap->{pnam} = $row->get_column('sbpname');
		$satmap->{pfrm} = $row->get_column('sbpfirma');
		$satmap->{plnd} = $row->get_column('sbpland');
		push( @{ $data{'sat'} }, $satmap );
	}

	# the total number of rows for pager
	$data{'count'} = $rowscount;

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

### SINGLE ( arg1 == uidx ) or MULTI ( arg1 == 'm' ) ###
sub satext_grid : Path('/satext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $uidx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satext_grid /UIDX $uidx/ - [ $info ]");
#]]
}

# GET
sub satext_grid_GET  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row, %data );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satext_grid_GET /UIDX $uidx/ - [ $info ]");
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
	$m = $c->model('katamaDB::signalbezug');

	# find record we are looking for
	$row = $m->find( $uidx );

	if ( !defined($row) || $row->sb_type != 1 ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# map result row into JSON data array
	$data{'sat'} = [ get_sat($row) ];

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

# SINGLE POST
sub satext_grid_POST  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row, $data, $rec );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satext_grid_POST /UIDX $uidx/ - [ $info ]");
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

	# UPDATE or CREATE for multiple rows ( /satext/m )
	if ( $uidx eq 'm' ) {
		return satext_grid_multi_post( $self, $c, $data );
	}

	# hash index of data for particular table
	$data = $data->{'sat'}[0];

#[[
	my $key;
	foreach $key ( keys %$data ) {
		$c->log->debug("RECEIVED Key $key => ".$data->{$key}) if (defined($data->{$key}));
	}
#]]

	# map received data to the table columns
	$rec = set_sat($data);
	delete $rec->{guid} if(defined($rec->{guid}));

	# do adjustments for UPDATE
	if( $uidx ) {
	}
	# do adjustments for CREATE
	else {
		$rec->{sb_type} = 1;
	}

#[[
	foreach $key ( keys %$rec) {
		$c->log->debug("MAPPED DATA to Key $key => ".$rec->{$key});
	}
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::signalbezug');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		### UPDATE ########################
		if ( $uidx ) {

			# first find record to update
			$row = $m->find( $uidx );

			if ( !defined($row) || $row->sb_type != 1 ) {
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
sub satext_grid_DELETE  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satext_grid_DELETE /UIDX $uidx/ - [ $info ]");
#]]

	# don't process dummy record which has uidx 0
	if( $uidx == 0 ) {
		return $self->status_bad_request( $c,
			message => "DELETE_idbad" );
	}

	# pickup the model for this controler
	$m = $c->model('katamaDB::signalbezug');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {
		$row = $m->find($uidx);

		if ( !defined($row) || $row->sb_type != 1 ) {
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
*satext_grid_PUT = *satext_grid_POST;

# MULTI POST
sub satext_grid_multi_post {
	my ( $self, $c, $data ) = @_;
	my ( $m, @rowobjs, $row, @recobjs, $rec, $datarec, $uidx, $guid );

#[[
	$c->log->debug("###### DEBUGGE: satext_grid_multi_post");
#]]

	# hash index of data for particular table
	$data = $data->{'sat'};

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

		$rec = set_sat($datarec);

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
			$rec->{sb_type} = 1;
		}

		push ( @recobjs, $rec );

#[[
		foreach $key ( keys %$rec) {
			$c->log->debug("MAPPED DATA to Key $key => ".$rec->{$key});
		}
#]]
	}

	# pickup the model for this controler
	$m = $c->model('katamaDB::signalbezug');

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

				if ( !defined($row) || $row->sb_type != 1 ) {
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

# END #########  signalbezug  #########


1;
