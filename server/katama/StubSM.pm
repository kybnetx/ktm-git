#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1. StubSM - name of this controller
# 2. STUBSM_TABLEABBR - table abbreviation for mapping functions
# 4. STUBSM_RESTMODEL - application DB model for REST interface
# 5. STUBSM_RESTACTION - actions of REST interface
# 6. STUBSM_ACTIONPATH - path to access actions of REST interface
#


package katama::Controller::StubSM;

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

	$c->response->body('Matched katama::Controller::StubSM');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


### mapping functions ###

sub set_STUBSM_TABLEABBR {
	my $row = shift;
	my %n;
		$n{'uidx'} = $row->{uidx} if (defined($row->{uidx}));
# ----------------------------------
#		$n{''} = $row->{} if (defined($row->{}));
	return \%n
}


sub get_STUBSM_TABLEABBR {
	my $row = shift;
	my %e = (
		uidx => $row->uidx,
# ----------------------------------
#		=> $row->,
	);
	return \%e
}


### data selection ###

sub selectmodel_NAME_STUBSM_TABLEABBR {
	my ( $self, $c, $cond ) = @_;
	my ( $m, $ee, @rowobjs, $row, %data );

	# pickup the model for this controler
	$m = $c->model('katamaDB::STUBSM_RESTMODEL');

	# pickup records
	@rowobjs = $m->search(
		$cond,
		{
			# belongs_to relations to create join
			join => [ qw/ b2_XXX / ],
			'+select' => [ qw/ b2_XXX.name / ],
			'+as' => [ qw/ XXX_name / ]
		}
	) or return 0;

	# map result row into JSON data array
	$data{'STUBSM_TABLEABBR'} = ();
	for $row ( @rowobjs ) {
		# don't take dummy record which has uidx 0
		next if ($row->uidx == 0);

		# call basic mapper
		$ee = get_STUBSM_TABLEABBR($row);

		# additional grid-specific mappings
		switch ($row->STUBSM_TABLEABBR_type) {
			case 1 {
				$ee->{''} = '';
				$ee->{'nam'} = $row->get_column('XXX_name');
			}
		}

		push( @{ $data{'STUBSM_TABLEABBR'} }, $ee );
	}

	return \%data;
}


###### REST service  ######

### ALL (no args) ###
sub STUBSM_RESTACTION_all : Path('/STUBSM_ACTIONPATH') : Args(0) : ActionClass('REST') {
	my ( $self, $c ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUBSM_RESTACTION_all [ $info ]");
#]]
}

# GET
sub STUBSM_RESTACTION_all_GET  {
	my ( $self, $c ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUBSM_RESTACTION_all_GET [ $info ]");
#]]

	my $data = selectmodel_NAME_STUBSM_TABLEABBR( $self, $c, undef );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

### PAGED ( arg1 == page ) ###
sub STUBSM_RESTACTION_page : Path('/STUBSM_ACTIONPATH/p') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $page ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUBSM_RESTACTION_page /Page $page/ - [ $info ]");
#]]
}


sub STUBSM_RESTACTION_page_GET  {
	my ( $self, $c, $page ) = @_;
	my ( %data );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUBSM_RESTACTION_page_GET /Page $page/ - [ $info ]");
#]]

	$data{'OK'} = 'Not implemnted';

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

### SINGLE ( arg1 == uidx ) or MULTI ( arg1 == 'm' ) ###
sub STUBSM_RESTACTION : Path('/STUBSM_ACTIONPATH') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $uidx ) = @_;
#[[
	my $info = $c->request->content_type;
#]]
	if ( $uidx eq 'p' ) {
#[[
		$c->log->debug("###### DEBUGGE: forwarding to /STUBSM_ACTIONPATH/p/0");
#]]
		$c->forward('/stubsm/STUBSM_RESTACTION_page', ['0']);
		$c->detach();
	}
#[[
	$c->log->debug("###### DEBUGGE: STUBSM_RESTACTION /UIDX $uidx/ - [ $info ]");
#]]
}

# GET
sub STUBSM_RESTACTION_GET  {
	my ( $self, $c, $uidx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUBSM_RESTACTION_GET /UIDX $uidx/ - [ $info ]");
#]]

	# this is to deal with unRESTy clients who send 'unresty' arg
    $uidx = $c->request->param('uidx') if ( $uidx eq 'unresty' );
	if( !defined($uidx) ) {
		return $self->status_bad_request( $c,
			message => "GET_idmissing" );
	}

	# don't process dummy record which has uidx 0
	if( $uidx == 0 ) {
		return $self->status_bad_request( $c,
			message => "GET_idbad" );
	}

	my $data = selectmodel_NAME_STUBSM_TABLEABBR( $self, $c, { 'me.uidx' => $uidx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# SINGLE POST
sub STUBSM_RESTACTION_POST  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row, $data, $rec );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUBSM_RESTACTION_POST /UIDX $uidx/ - [ $info ]");
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

	# UPDATE or CREATE for multiple rows ( /STUBSM_ACTIONPATH/m )
	if ( $uidx eq 'm' ) {
		return STUBSM_RESTACTION_multi_post( $self, $c, $data );
	}

	# hash index of data for particular table
	$data = $data->{'STUBSM_TABLEABBR'}[0];

#[[
	my $key;
	foreach $key ( keys %$data ) {
		$c->log->debug("RECEIVED Key $key => ".$data->{$key}) if (defined($data->{$key}));
	}
#]]

	# map received data to the table columns
	$rec = set_STUBSM_TABLEABBR($data);
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
	$m = $c->model('katamaDB::STUBSM_RESTMODEL');

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
sub STUBSM_RESTACTION_DELETE  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: STUBSM_RESTACTION_DELETE /UIDX $uidx/ - [ $info ]");
#]]

	# don't process dummy record which has uidx 0
	if( $uidx == 0 ) {
		return $self->status_bad_request( $c,
			message => "DELETE_idbad" );
	}

	# pickup the model for this controler
	$m = $c->model('katamaDB::STUBSM_RESTMODEL');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {
		$row = $m->find($uidx);

		if ( !defined($row) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "DELETE_notfound" );
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
*STUBSM_RESTACTION_PUT = *STUBSM_RESTACTION_POST;

# MULTI POST
sub STUBSM_RESTACTION_multi_post {
	my ( $self, $c, $data ) = @_;
	my ( $m, @rowobjs, $row, @recobjs, $rec, $datarec, $uidx, $guid );

#[[
	$c->log->debug("###### DEBUGGE: STUBSM_RESTACTION_multi_post");
#]]

	# hash index of data for particular table
	$data = $data->{'STUBSM_TABLEABBR'};

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

		$rec = set_STUBSM_TABLEABBR($datarec);

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
	$m = $c->model('katamaDB::STUBSM_RESTMODEL');

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
