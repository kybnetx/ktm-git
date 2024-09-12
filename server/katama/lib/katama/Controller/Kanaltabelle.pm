#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1. Kanaltabelle - name of this controller
# 2. kt - table abbreviation for mapping functions
# 4. kanaltabelle - application DB model for REST interface
# 5. ktext_grid - actions of REST interface
# 6. ktext - path to access actions of REST interface
#


package katama::Controller::Kanaltabelle;

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

	$c->response->body('Matched katama::Controller::Kanaltabelle');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut

sub set_kt {
	my $row = shift;
	my %n;
		$n{'uidx'} = $row->{uidx} if (defined($row->{uidx}));
# ----------------------------------
		$n{'kf_idx'} = $row->{kfid} if (defined($row->{kfid}));
		$n{'inactive'} = $row->{ina} if (defined($row->{ina}));
	return \%n
}

### data selection ###

# returns JSON array for table generation
#sub selectmodel_PROGRAMM_kt_a {
#	my ( $self, $c, $sq_idx ) = @_;
#	my ( $m, $msb, @rowobjs, $row, $cond );
#
#	# first find out what kind of 'kanaltabelle' we are looking for
#	# (referencing 'signalbezug' or 'sbprovider' - the flag up_issbprovkt tells)
#	$msb = $c->model('katamaDB::signalbezug');
#
#	$row = $msb->find( $sq_idx );
#	if($row->up_issbprovkt) {
#		$cond = { 'me.sbp_idx' => $row->sbp_idx };
#	}
#	else {
#		$cond = { 'me.sq_idx' => $sq_idx };
#	}
#
#	# pickup the main model for this controler
#	$m = $c->model('katamaDB::kanaltabelle');
#
#	# pickup records
#	@rowobjs = $m->search(
#		$cond,
#		{
#			# belongs_to relations to create join
#			join => [ 'b2_pg', 'b2_kf' ],
#			'+select' => [ qw/ b2_pg.pg_type b2_pg.name b2_kf.kanal / ],
#			'+as' => [ qw/ pgtype pgname kfkanal / ]
#		}
#	) or return 0;
#
#	my @data = ( ['Typ', 'Name', 'Kanal'] );
#
#	for $row ( @rowobjs ) {
#		push( @data, [
#			katama::Common::get_pgtype($row->get_column('pgtype')),
#			$row->get_column('pgname'),
#			$row->get_column('kfkanal'),
#		] );
#	}
#
#	return (\@data);
#}


# returns JSON hashish for Ext JsonStore
sub selectmodel_PROGRAMM_kt_h {
	my ( $self, $c, $cond ) = @_;
	my ( $m, @rowobjs, $row, $pgtid );

	# pickup the model for this controler
	$m = $c->model('katamaDB::signalquellenkanal');

	# pickup records
	@rowobjs = $m->search(
		$cond,
		{
			# belongs_to relations to create join
			join => {
				 'b2_kt' => [ 'b2_kf', 'b2_pg' ]
			},
			'+select' => [ qw/ b2_kt.sb_idx b2_kt.pg_idx b2_pg.pg_type b2_pg.name b2_kt.kf_idx b2_kf.kanal / ],
			'+as' => [ qw/ ktsbidx ktpgidx pgtype pgname ktkfidx kfkanal / ]
		}
	) or return 0;

	my %data = ();

	for $row ( @rowobjs ) {
		$pgtid = $row->get_column('pgtype');
		push( @{ $data{'kt'} }, {
			sqid => $row->sq_idx,
			uidx => $row->kt_idx,
			sbid => $row->get_column('ktsbidx'),
			pgid => $row->get_column('ktpgidx'),
			kfid => $row->get_column('ktkfidx'),
			nam => $row->get_column('pgname'),
			kfk => $row->get_column('kfkanal'),
			pgt => katama::Common::get_pgtype($pgtid),
		});
	}

	return (\%data);
}


###### REST service  #####

### ALL ( arg1 == sq_idx ) ###
sub ktext_grid_all : Path('/ktext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $sq_idx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: ktext_grid_all /sq_idx $sq_idx/ [ $info ]");
#]]
}

# GET
sub ktext_grid_all_GET  {
	my ( $self, $c, $sq_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: ktext_grid_all_GET /sq_idx $sq_idx/ [ $info ]");
#]]

	my $data = selectmodel_PROGRAMM_kt_h( $self, $c, { 'me.sq_idx' => $sq_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

#### ALL TABLE ( arg1 == sq_idx ) ###
#sub ktext_grid_table : Path('/ktext_tab') : Args(1) : ActionClass('REST') {
#	my ( $self, $c, $sq_idx ) = @_;
##[[
#	my $info = $c->request->content_type;
#	$c->log->debug("###### DEBUGGE: ktext_grid_table /sq_idx $sq_idx/ [ $info ]");
##]]
#}
#
## GET
#sub ktext_grid_table_GET  {
#	my ( $self, $c, $sq_idx ) = @_;
#
##[[
#	my $info = $c->request->content_type;
#	$c->log->debug("###### DEBUGGE: ktext_grid_table_GET /sq_idx $sq_idx/ [ $info ]");
##]]
#
#	my $data = selectmodel_PROGRAMM_kt_a( $self, $c, $sq_idx );
#
#	if ( ! $data ) {
#		return $self->status_not_found( $c,
#			message => "GET_notfound" );
#	}
#
#	# return result set
#	return $self->status_ok( $c, entity => $data );
#}

### SINGLE ( arg1 == sq_idx, arg2 == kt_idx ) ###
sub ktext_grid : Path('/ktext') : Args(2) : ActionClass('REST') {
	my ( $self, $c, $sq_idx, $kt_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: ktext_grid /sq_idx $sq_idx, kt_idx $kt_idx/ - [ $info ]");
#]]
}

# GET
sub ktext_grid_GET  {
	my ( $self, $c, $sq_idx, $kt_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: ktext_grid_GET /sq_idx $sq_idx, kt_idx $kt_idx/ - [ $info ]");
#]]

	my ( $data, $t ) = selectmodel_PROGRAMM_kt_h( $self, $c, { 'me.sq_idx'=>$sq_idx, 'me.kt_idx'=>$kt_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# POST
sub ktext_grid_POST  {
	my ( $self, $c, $sq_idx, $kt_idx ) = @_;
	my ( $m, $msq, $row );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: ktext_grid_POST /sq_idx $sq_idx, kt_idx $kt_idx/ - [ $info ]");
#]]

	# UPDATE for multiple rows ( /ktext/sq_idx/m )
	if ( $kt_idx eq 'm' ) {
		my $data = $c->req->data;
		if (!defined($data)) {
			return $self->status_bad_request( $c,
				message => "POST_datamissing" );
		}
		return ktext_grid_multi_post_update( $self, $c, $data );
	}
}

# we don't use PUT
*ktext_grid_PUT = *ktext_grid_POST;



# MULTI POST
sub ktext_grid_multi_post_update {
	my ( $self, $c, $data ) = @_;
	my ( $m, @rowobjs, $row, @recobjs, $rec, $datarec, $uidx, $guid );

#[[
	$c->log->debug("###### DEBUGGE: ktext_grid_multi_post_update");
#]]

	# hash index of data for particular table
	$data = $data->{'kt'};

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
		$rec = set_kt($datarec);

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
	$m = $c->model('katamaDB::kanaltabelle');

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
