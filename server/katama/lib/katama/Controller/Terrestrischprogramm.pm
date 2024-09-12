#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1. Terrestrischprogramm - name of this controller
# 2. terrpg - table abbreviation for mapping functions
# 4. terrprogfreq - application DB model for REST interface
# 5. terrpgext_grid - actions of REST interface
# 6. terrpgext - path to access actions of REST interface
#


package katama::Controller::Terrestrischprogramm;

use strict;
use warnings;
use Switch;
use katama::Common;
use Encode qw/encode decode/;

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

	$c->response->body('Matched katama::Controller::Terrestrischprogramm');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut

sub set_terrpg {
	my $row = shift;
	my %n;
		$n{'uidx'} = $row->{uidx} if (defined($row->{uidx}));
# ----------------------------------
		$n{'freq'} = $row->{frq} if (defined($row->{frq}));
#		$n{'polar'} = $row->{pol} if (defined($row->{pol}));
#		$n{'fec'} = $row->{fec} if (defined($row->{fec}));
#		$n{'fft'} = $row->{fft} if (defined($row->{fft}));
#		$n{'guard'} = $row->{grd} if (defined($row->{grd}));
#		$n{'mod_type'} = $row->{mod} if (defined($row->{mod}));
		$n{'sig_type'} = $row->{sig} if (defined($row->{sig}));
		$n{'bc_type'} = $row->{bct} if (defined($row->{bct}));
#		$n{'iscryp'} = ($row->{cry} eq 'true' ? 1 : 0 ) if (defined($row->{cry}));
		$n{'iscryp'} = $row->{cry} if (defined($row->{cry}));
	return \%n
}

# this is array for RowExpander UI
sub get_terrpg_a {
	my $row = shift;
	my @a = (
#		$row->uidx,
# ----------------------------------
		$row->freq,
#		$row->polar,
#		$row->sig_type,
#		$row->bc_type,
		($row->iscryp ? ' Ja' : ' Nein')
	);
	return @a
}

# this is hashish for connector grid
sub get_terrpg_h {
	my $row = shift;
	my %e = (
		uidx => $row->uidx,
# ----------------------------------
		frq	=> $row->freq,
#		pol	=> $row->polar,
#		fec => $row->fec,
#		fft => $row->fft,
#		grd => $row->guard,
#		mod => $row->mod_type,
		sig	=> $row->sig_type,
		bct	=> $row->bc_type,
		cry	=> $row->iscryp
	);
	return %e
}

### data selection ###

# returns JSON array for table generation
sub selectmodel_PROGRAMM_terrpg_a {
	my ( $self, $c, $cond, $table ) = @_;
	my ( $m, @rowobjs, $row );

	# pickup the model for this controler
	$m = $c->model('katamaDB::terrprogfreq');

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

	my @data = ( ['Typ', 'Name', 'Freq', decode('utf8', 'Verschlüßelt') ] );

	for $row ( @rowobjs ) {
		push( @data, [
			katama::Common::get_pgtype($row->get_column('pgtype')),
			$row->get_column('pgname'),
			get_terrpg_a($row)
		] );
	}

	return (\@data);
}


# returns JSON hashish for Ext JsonStore
sub selectmodel_PROGRAMM_terrpg_h {
	my ( $self, $c, $cond, $table ) = @_;
	my ( $m, @rowobjs, $row );

	# pickup the model for this controler
	$m = $c->model('katamaDB::terrprogfreq');

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
		push( @{ $data{'terrpg'} }, {
			sbid => $row->sb_idx,
			pgid => $row->pg_idx,
			pgt => katama::Common::get_pgtype($row->get_column('pgtype')),
			nam => $row->get_column('pgname'),
			get_terrpg_h($row)
		});
#[[
		$c->log->debug("get_pgtype ".$row->get_column('pgtype'));
#]]
	}

	return (\%data);
}


###### REST service  ######

### ALL ( arg1 == sb_idx ) ###
sub terrpgext_grid_all : Path('/terrpgext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $sb_idx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: terrpgext_grid_all /sb_idx $sb_idx/ [ $info ]");
#]]
}

# GET
sub terrpgext_grid_all_GET  {
	my ( $self, $c, $sb_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: terrpgext_grid_all_GET /sb_idx $sb_idx/ [ $info ]");
#]]

	my $data = selectmodel_PROGRAMM_terrpg_h( $self, $c, { 'me.sb_idx' => $sb_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

### ALL TABLE ( arg1 == sb_idx ) ###
sub terrpgext_grid_table : Path('/terrpgext_tab') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $sb_idx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: terrpgext_grid_table /sb_idx $sb_idx/ [ $info ]");
#]]
}

# GET
sub terrpgext_grid_table_GET  {
	my ( $self, $c, $sb_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: terrpgext_grid_table_GET /sb_idx $sb_idx/ [ $info ]");
#]]

	my $data = selectmodel_PROGRAMM_terrpg_a( $self, $c, { 'me.sb_idx' => $sb_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data );
}

### SINGLE ( arg1 == sb_idx, arg2 == pg_idx ) ###
sub terrpgext_grid : Path('/terrpgext') : Args(2) : ActionClass('REST') {
	my ( $self, $c, $sb_idx, $pg_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: terrpgext_grid /sb_idx $sb_idx, pg_idx $pg_idx/ - [ $info ]");
#]]
}

# GET
sub terrpgext_grid_GET  {
	my ( $self, $c, $sb_idx, $pg_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: terrpgext_grid_GET /sb_idx $sb_idx, pg_idx $pg_idx/ - [ $info ]");
#]]

	my ( $data, $t ) = selectmodel_PROGRAMM_terrpg_h( $self, $c, { 'me.sb_idx'=>$sb_idx, 'me.pg_idx'=>$pg_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# POST
sub terrpgext_grid_POST  {
	my ( $self, $c, $sb_idx, $pg_idx ) = @_;
	my ( $m, $msb, $mpg, $row, %rec );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: terrpgext_grid_POST /sb_idx $sb_idx, pg_idx $pg_idx/ - [ $info ]");
#]]

	# UPDATE for multiple rows ( /terrpgext/sb_idx/m )
	if ( $pg_idx eq 'm' ) {
		my $data = $c->req->data;
		if (!defined($data)) {
			return $self->status_bad_request( $c,
				message => "POST_datamissing" );
		}
		return terrpgext_grid_multi_post_update( $self, $c, $data );
	}

	# map received data to the table columns
	$rec{'sb_idx'} = $sb_idx;
	$rec{'pg_idx'} = $pg_idx;

	# pickup the model for this controler
	$m = $c->model('katamaDB::terrprogfreq');
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
sub terrpgext_grid_DELETE  {
	my ( $self, $c, $sb_idx, $pg_idx ) = @_;
	my ( $m, $rs );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: terrpgext_grid_DELETE /sb_idx $sb_idx, pg_idx $pg_idx/ - [ $info ]");
#]]

	# pickup the model for this controller
	$m = $c->model('katamaDB::terrprogfreq');

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
*terrpgext_grid_PUT = *terrpgext_grid_POST;



# MULTI POST
sub terrpgext_grid_multi_post_update {
	my ( $self, $c, $data ) = @_;
	my ( $m, @rowobjs, $row, @recobjs, $rec, $datarec, $uidx, $guid );

#[[
	$c->log->debug("###### DEBUGGE: terrpgext_grid_multi_post_update");
#]]

	# hash index of data for particular table
	$data = $data->{'terrpg'};

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
		$rec = set_terrpg($datarec);

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
	$m = $c->model('katamaDB::terrprogfreq');

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
