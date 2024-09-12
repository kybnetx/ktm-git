#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1. Satellitprogramm - name of this controller
# 2. satpg - table abbreviation for mapping functions
# 4. satprogfreq - application DB model for REST interface
# 5. satpgext_grid - actions of REST interface
# 6. satpgext - path to access actions of REST interface
#


package katama::Controller::Satellitprogramm;

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

	$c->response->body('Matched katama::Controller::Satellitprogramm');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut

sub set_satpg {
	my $row = shift;
	my %n;
		$n{'uidx'} = $row->{uidx} if (defined($row->{uidx}));
# ----------------------------------
		$n{'freq'} = $row->{frq} if (defined($row->{frq}));
		$n{'zwfreq'} = $row->{zfr} if (defined($row->{zfr}));
		$n{'polar'} = $row->{pol} if (defined($row->{pol}));
		$n{'symbol'} = $row->{sym} if (defined($row->{sym}));
		$n{'transp'} = $row->{trn} if (defined($row->{trn}));
		$n{'spot'} = $row->{spt} if (defined($row->{spt}));
		$n{'sig_type'} = $row->{sig} if (defined($row->{sig}));
		$n{'bc_type'} = $row->{bct} if (defined($row->{bct}));
#		$n{'iscryp'} = ($row->{cry} eq 'true' ? 1 : 0 ) if (defined($row->{cry}));
		$n{'iscryp'} = $row->{cry} if (defined($row->{cry}));
	return \%n
}

# this is array for RowExpander UI
sub get_satpg_a {
	my $row = shift;
	my @a = (
#		$row->uidx,
# ----------------------------------
		$row->freq,
#		$row->zwfreq,
		$row->polar,
#		$row->symbol,
#		$row->transp,
#		$row->spot,
#		$row->sig_type,
#		$row->bc_type,
#		$row->iscryp
	);
	return @a
}

# this is hashish for connector grid
sub get_satpg_h {
	my $row = shift;
	my %e = (
		uidx => $row->uidx,
# ----------------------------------
		frq	=> $row->freq,
		zfr	=> $row->zwfreq,
		pol	=> $row->polar,
		sym	=> $row->symbol,
		trn	=> $row->transp,
		spt	=> $row->spot,
		sig	=> $row->sig_type,
		bct	=> $row->bc_type,
		cry	=> $row->iscryp
	);
	return %e
}

### data selection ###

# returns JSON array for table generation
sub selectmodel_PROGRAMM_satpg_a {
	my ( $self, $c, $cond, $table ) = @_;
	my ( $m, @rowobjs, $row );

	# pickup the model for this controler
	$m = $c->model('katamaDB::satprogfreq');

	# pickup records
	@rowobjs = $m->search(
		$cond,
		{
			# belongs_to relations to create join
			join => [ 'b2_pg' ],
			'+select' => [ qw/ b2_pg.pg_type b2_pg.name / ],
			'+as' => [ qw/ pgtype pgname / ]
		}
	) or return 0;

	my @data = ( ['Typ', 'Name', 'Freq', 'Pol'] );

	for $row ( @rowobjs ) {
		push( @data, [
			katama::Common::get_pgtype($row->get_column('pgtype')),
			$row->get_column('pgname'),
			get_satpg_a($row)
		] );
	}

	return (\@data);
}


# returns JSON hashish for Ext JsonStore
sub selectmodel_PROGRAMM_satpg_h {
	my ( $self, $c, $cond, $table ) = @_;
	my ( $m, @rowobjs, $row );

	# pickup the model for this controler
	$m = $c->model('katamaDB::satprogfreq');

	# pickup records
	@rowobjs = $m->search(
		$cond,
		{
			# belongs_to relations to create join
			join => [ 'b2_pg' ],
			'+select' => [ qw/ b2_pg.pg_type b2_pg.name / ],
			'+as' => [ qw/ pgtype pgname / ]
		}
	) or return 0;

	my %data = ();

	for $row ( @rowobjs ) {
		push( @{ $data{'satpg'} }, {
			sbid => $row->sb_idx,
			pgid => $row->pg_idx,
			pgt => katama::Common::get_pgtype($row->get_column('pgtype')),
			nam => $row->get_column('pgname'),
			get_satpg_h($row)
		});
#[[
		$c->log->debug("get_pgtype ".$row->get_column('pgtype'));
#]]
	}

	return (\%data);
}


###### REST service  ######

### ALL ( arg1 == sb_idx ) ###
sub satpgext_grid_all : Path('/satpgext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $sb_idx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satpgext_grid_all /sb_idx $sb_idx/ [ $info ]");
#]]
}

# GET
sub satpgext_grid_all_GET  {
	my ( $self, $c, $sb_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satpgext_grid_all_GET /sb_idx $sb_idx/ [ $info ]");
#]]

	my $data = selectmodel_PROGRAMM_satpg_h( $self, $c, { 'me.sb_idx' => $sb_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

### ALL TABLE ( arg1 == sb_idx ) ###
sub satpgext_grid_table : Path('/satpgext_tab') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $sb_idx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satpgext_grid_table /sb_idx $sb_idx/ [ $info ]");
#]]
}

# GET
sub satpgext_grid_table_GET  {
	my ( $self, $c, $sb_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satpgext_grid_table_GET /sb_idx $sb_idx/ [ $info ]");
#]]

	my $data = selectmodel_PROGRAMM_satpg_a( $self, $c, { 'me.sb_idx' => $sb_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data );
}

### SINGLE ( arg1 == sb_idx, arg2 == pg_idx ) ###
sub satpgext_grid : Path('/satpgext') : Args(2) : ActionClass('REST') {
	my ( $self, $c, $sb_idx, $pg_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satpgext_grid /sb_idx $sb_idx, pg_idx $pg_idx/ - [ $info ]");
#]]
}

# GET
sub satpgext_grid_GET  {
	my ( $self, $c, $sb_idx, $pg_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satpgext_grid_GET /sb_idx $sb_idx, pg_idx $pg_idx/ - [ $info ]");
#]]

	my ( $data, $t ) = selectmodel_PROGRAMM_satpg_h( $self, $c, { 'me.sb_idx'=>$sb_idx, 'me.pg_idx'=>$pg_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# POST
sub satpgext_grid_POST  {
	my ( $self, $c, $sb_idx, $pg_idx ) = @_;
	my ( $m, $msb, $mpg, $row, %rec );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satpgext_grid_POST /sb_idx $sb_idx, pg_idx $pg_idx/ - [ $info ]");
#]]

	# UPDATE for multiple rows ( /satpgext/sb_idx/m )
	if ( $pg_idx eq 'm' ) {
		my $data = $c->req->data;
		if (!defined($data)) {
			return $self->status_bad_request( $c,
				message => "POST_datamissing" );
		}
		return satpgext_grid_multi_post_update( $self, $c, $data );
	}

	# map received data to the table columns
	$rec{'sb_idx'} = $sb_idx;
	$rec{'pg_idx'} = $pg_idx;

	# pickup the model for this controler
	$m = $c->model('katamaDB::satprogfreq');
	$mpg = $c->model('katamaDB::programm');
	$msb = $c->model('katamaDB::signalbezug');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		### CREATE ########################

		# check here for the existence of the keys in related tables
		$row = $msb->find($sb_idx);

		if ( !defined($row) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "POST_sb_relnotfound" );
		}

		$row = $mpg->find($pg_idx);

		if ( !defined($row) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "POST_sb_relnotfound" );
		}

		# check here for duplicates
		if ( defined( $m->search( { 'me.sb_idx' => $sb_idx, 'me.pg_idx' => $pg_idx } )->next ) ) {
			katama::Common::unlock_app($c);
			return $self->status_bad_request( $c,
				message => "POST_duplicate" );
		}

		# create a brand new record with received data
		$row = $m->create( \%rec );

		# add new programm to the signalquelle tree
		katama::Common::sb_add_sqsb_programm($self, $c, $sb_idx, $pg_idx);

		katama::Common::unlock_app($c);

#[[
		$c->log->debug("CREATED!");
#]]

		# status created
		return $self->status_created( $c,
			location => $c->req->uri->as_string,
			entity => { sbid => $sb_idx, pgid => $pg_idx } );
	}

	# HANDLE LOCK ERROR HERE
	else {
		return $self->status_not_found( $c,
			message => "POST_cannotlock" );
	}

	# never reached
}

# DELETE
sub satpgext_grid_DELETE  {
	my ( $self, $c, $sb_idx, $pg_idx ) = @_;
	my ( $m, $rs );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: satpgext_grid_DELETE /sb_idx $sb_idx, pg_idx $pg_idx/ - [ $info ]");
#]]

	# pickup the model for this controller
	$m = $c->model('katamaDB::satprogfreq');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		$rs = $m->search( { 'me.sb_idx' => $sb_idx, 'me.pg_idx' => $pg_idx } );

		if ( !defined($rs->next) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "DELETE_notfound" );
		}

		$rs->delete;

		# delete programm from signalquelle tree
		katama::Common::sb_delete_sqsb_programm($self, $c, $sb_idx, $pg_idx);

		katama::Common::unlock_app($c);

#[[
		$c->log->debug("DELETED!");
#]]
		return $self->status_ok( $c,
			entity => { sbid => $sb_idx, pgid => $pg_idx } );
	}

	# HANDLE LOCK ERROR HERE
	else {
		return $self->status_not_found( $c,
			message => "DELETE_cannotlock" );
	}

	# never reached
}

# we don't use PUT
*satpgext_grid_PUT = *satpgext_grid_POST;



# MULTI POST
sub satpgext_grid_multi_post_update {
	my ( $self, $c, $data ) = @_;
	my ( $m, @rowobjs, $row, @recobjs, $rec, $datarec, $uidx, $guid );

#[[
	$c->log->debug("###### DEBUGGE: satpgext_grid_multi_post_update");
#]]

	# hash index of data for particular table
	$data = $data->{'satpg'};

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
		$rec = set_satpg($datarec);

		if ( !defined( $rec->{uidx} ) ) {
			return $self->status_bad_request( $c,
				message => "POST_uidxdmissing" );
		}

		push ( @recobjs, $rec );
#[[
		foreach $key ( keys %$rec) {
			$c->log->debug("MAPPED DATA to Key $key => ".$rec->{$key});
		}
#]]
	}

	# pickup the model for this controler
	$m = $c->model('katamaDB::satprogfreq');

	# return hash of rows for status 'UPD' and 'ERR'
	my %ret = ();

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		for $rec ( @recobjs ) {

			### UPDATE ########################

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
