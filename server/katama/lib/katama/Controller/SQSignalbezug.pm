#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1. SQSignalbezug - name of this controller
# 2. sqsb - table abbreviation for mapping functions
# 4. signalquellensignal - application DB model for REST interface
# 5. sqsbext_grid - actions of REST interface
# 6. sqsbext - path to access actions of REST interface
#


package katama::Controller::SQSignalbezug;

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

	$c->response->body('Matched katama::Controller::SQSignalbezug');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


### data selection ###

# returns JSON hashish for Ext JsonStore
sub selectmodel_SIGNALBEZUG_sqsb_h {
	my ( $self, $c, $cond ) = @_;
	my ( $m, @rowobjs, $row, %data );
	my ( $kennung1, $kennung2, $sat_pos, $up_strasse, $up_hausnr, $up_hausnrzus, $up_plz, $up_ort );

	# pickup the model for this controler
	$m = $c->model('katamaDB::signalquellensignal');

	# pickup records
	@rowobjs = $m->search(
		$cond,
		{
			join => [ 'b2_sb' ],
			'+select' => [ qw/ b2_sb.sb_type b2_sb.kennung1 b2_sb.kennung2 b2_sb.sat_pos b2_sb.up_strasse b2_sb.up_hausnr b2_sb.up_hausnrzus b2_sb.up_plz b2_sb.up_ort / ],
			'+as' => [ qw/ sbtype sbkennung1 sbkennung2 sbsat_pos sbup_strasse sbup_hausnr sbup_hausnrzus sbup_plz sbup_ort / ]
		}
	) or return 0;

	$data{'sqsb'} = ();
	for $row ( @rowobjs ) {

		my $info = '';
		my $sbtype = $row->get_column('sbtype');

		my %e = ();
		$e{'sqid'} = $row->sq_idx;
		$e{'sbid'} = $row->sb_idx;
		$e{'sbt'} = katama::Common::get_sbtype($sbtype);
		$e{'kn1'} = $row->get_column('sbkennung1');

		# satellit
		if($sbtype == 1) {
			$kennung2 = $row->get_column('sbkennung2');
			$sat_pos = $row->get_column('sbsat_pos');
			$info = ' [Position: '.$sat_pos.']' if($sat_pos);
			$info = $kennung2.$info if($kennung2);
		}
		# kabel
		elsif ($sbtype == 2) {
			$kennung2 = $row->get_column('sbkennung2');
			$up_strasse = $row->get_column('sbup_strasse');
			$up_hausnr = $row->get_column('sbup_hausnr');
			$up_hausnrzus = $row->get_column('sbup_hausnrzus');
			$up_plz = $row->get_column('sbup_plz');
			$up_ort = $row->get_column('sbup_ort');
			$info .= $up_plz if($up_plz);
			$info .= ' '.$up_ort if($up_ort);
			$info .= ', '.$up_strasse if($up_strasse);
			$info .= ' '.$up_hausnr if($up_hausnr);
			$info .= ' ('.$up_hausnrzus.')' if($up_hausnrzus);
			$info = ' [Standort: '.$info.']' if($info);
			$info = $kennung2.$info if($kennung2);
		}
		# terrestrisch
		elsif ($sbtype == 3) {
			$kennung2 = $row->get_column('sbkennung2');
			$info = $kennung2.$info if($kennung2);
		}

		$e{'info'} = $info;

		push( @{ $data{'sqsb'} }, \%e );
	}

	return (\%data);
}


###### REST service  ######

### ALL ( arg1 == sq_idx ) ###
sub sqsbext_grid_all : Path('/sqsbext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $sq_idx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sqsbext_grid_all /sq_idx $sq_idx/ [ $info ]");
#]]
}

# GET
sub sqsbext_grid_all_GET  {
	my ( $self, $c, $sq_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sqsbext_grid_all_GET /sq_idx $sq_idx/ [ $info ]");
#]]

	my $data = selectmodel_SIGNALBEZUG_sqsb_h( $self, $c, { 'me.sq_idx' => $sq_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data );
}

### SINGLE ( arg1 == sq_idx, arg2 == sb_idx ) ###
sub sqsbext_grid : Path('/sqsbext') : Args(2) : ActionClass('REST') {
	my ( $self, $c, $sq_idx, $sb_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sqsbext_grid /sq_idx $sq_idx, sb_idx $sb_idx/ - [ $info ]");
#]]
}

# GET
sub sqsbext_grid_GET  {
	my ( $self, $c, $sq_idx, $sb_idx ) = @_;

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sqsbext_grid_GET /sq_idx $sq_idx, sb_idx $sb_idx/ - [ $info ]");
#]]

	my ( $data, $t ) = selectmodel_SIGNALBEZUG_sqsb_h( $self, $c, { 'me.sq_idx'=>$sq_idx, 'me.sb_idx'=>$sb_idx } );

	if ( ! $data ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# return result set
	return $self->status_ok( $c, entity => $data);
}

# POST
sub sqsbext_grid_POST  {
	my ( $self, $c, $sq_idx, $sb_idx ) = @_;
	my ( $m, $msq, $msb, $row, %rec );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sqsbext_grid_POST /sq_idx $sq_idx, sb_idx $sb_idx/ - [ $info ]");
#]]

	# map received data to the table columns
	$rec{'sq_idx'} = $sq_idx;
	$rec{'sb_idx'} = $sb_idx;

	# pickup the model for this controler
	$m = $c->model('katamaDB::signalquellensignal');
	$msq = $c->model('katamaDB::signalquelle');
	$msb = $c->model('katamaDB::signalbezug');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		### CREATE ########################

		# check here for the existence of the keys in related tables
		$row = $msq->find($sq_idx);

		if ( !defined($row) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "POST_relnotfound" );
		}

		$row = $msb->find($sb_idx);

		if ( !defined($row) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "POST_relnotfound" );
		}

		# check here for duplicates
		if ( defined( $m->search( { 'me.sq_idx' => $sq_idx, 'me.sb_idx' => $sb_idx } )->next ) ) {
			katama::Common::unlock_app($c);
			return $self->status_bad_request( $c,
				message => "POST_duplicate" );
		}

		# create a brand new record with received data
		$row = $m->create( \%rec );

		# create kanaltabelle for this signalbezug
		sqsbext_create_kanaltabelle($self, $c, $sq_idx, $sb_idx);

		katama::Common::unlock_app($c);

#[[
		$c->log->debug("CREATED!");
#]]

		# status created
		return $self->status_created( $c,
			location => $c->req->uri->as_string,
			entity => { sqid => $sq_idx, sbid => $sb_idx } );
	}

	# HANDLE LOCK ERROR HERE
	else {
		return $self->status_not_found( $c,
			message => "POST_cannotlock" );
	}

	# never reached
}

# DELETE
sub sqsbext_grid_DELETE  {
	my ( $self, $c, $sq_idx, $sb_idx ) = @_;
	my ( $m, $rs );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sqsbext_grid_DELETE /sq_idx $sq_idx, sb_idx $sb_idx/ - [ $info ]");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::signalquellensignal');

	# now lock access to the database to ensure atomicity
	if ( katama::Common::lock_app($c, 15) ) {

		$rs = $m->search( { 'me.sq_idx' => $sq_idx, 'me.sb_idx' => $sb_idx } );

		if ( !defined($rs->next) ) {
			katama::Common::unlock_app($c);
			return $self->status_not_found( $c,
				message => "DELETE_notfound" );
		}

		# delete kanaltabelle for this signalbezug
		sqsbext_delete_kanaltabelle($self, $c, $sq_idx, $sb_idx);

		$rs->delete;

		katama::Common::unlock_app($c);

#[[
		$c->log->debug("DELETED!");
#]]
		return $self->status_ok( $c,
			entity => { sqid => $sq_idx, sbid => $sb_idx } );
	}

	# HANDLE LOCK ERROR HERE
	else {
		return $self->status_not_found( $c,
			message => "DELETE_cannotlock" );
	}

	# never reached
}

# we don't use PUT
*sqsbext_grid_PUT = *sqsbext_grid_POST;

###############################################################################
### CREATE AND DELETE KANALTABELLE FOR SQ-SB & CASCADE SQ KIDS WITH NEW KT
###############################################################################

sub sqsbext_create_kanaltabelle  {
	my ( $self, $c, $sq_idx, $sb_idx ) = @_;
	my ( %join, $m, $msb, $mkt, $msq, $row, $pgrow, $sqrow, $kt_idx, $pg_idx, @sbprogs, @sqkids, $ktrow, @ktprogs );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sqsbext_create_kanaltabelle /sq_idx $sq_idx, sb_idx $sb_idx/ - [ $info ]");
#]]

	# pickup models we need
	$m = $c->model('katamaDB::signalquellenkanal');
	$mkt = $c->model('katamaDB::kanaltabelle');
	$msb = $c->model('katamaDB::signalbezug');
	$msq = $c->model('katamaDB::signalquelle');

	# first pickup some info about signalbezug
	$row = $msb->find( $sb_idx );

	# satellit programms
	if($row->sb_type == 1) {
		%join = ( join => 'spf_sb', '+select' => [ qw/ spf_sb.pg_idx / ] )
	}
	# kabel programms
	elsif($row->sb_type == 2) {
		if($row->up_issbprovkt) {
			%join = ( join => { 'b2_sbp' => 'kpf_sbp' }, '+select' => [ qw/ kpf_sbp.pg_idx / ] );
		}
		else {
			%join = ( join => 'kpf_sb', '+select' => [ qw/ kpf_sb.pg_idx / ] );
		}
	}
	# terrestrial programms
	else {
		%join = ( join => 'tpf_sb', '+select' => [ qw/ tpf_sb.pg_idx / ] );
	}

	$join{'+as'} = [ qw/ sbpgidx / ];

	### MULTIPLE CREATE ########################

	# get programms of that SB	
	@sbprogs = $msb->search( { 'me.uidx' => $sb_idx }, \%join ); 

	# store here new created kanal-programms of signalbezug
	@ktprogs = ();

	for $pgrow ( @sbprogs ) {

		$pg_idx = $pgrow->get_column('sbpgidx');

		# empty SB ignored (sentinel pg_idx 0)
		next if(!$pg_idx);

		# first create entry within kanaltabelle
		# sq_idx and sb_idx are also stored here for quick delete access
		# (instead of using reference through the connector signalquellekanal)
		$row = $mkt->create( { pg_idx => $pg_idx, sq_idx => $sq_idx, sb_idx => $sb_idx } );

		# find out the index of new record
		$kt_idx = $row->uidx;

		# store for later adding to children nodes
		push(@ktprogs, $kt_idx);

		# create link to the signalquelle
		$row = $m->create( { sq_idx => $sq_idx, kt_idx => $kt_idx } );
#[[
		$c->log->debug("CREATED for PG $pg_idx ---> KT $kt_idx");
#]]
	}

	# pickup all kids of the signalquelle
	if(katama::Common::sq_getallkids($c, $sq_idx) && @ktprogs) {
		@sqkids = $c->model('katamaDB::sq_getallkids')->search({});
		foreach $sqrow (@sqkids) {
			$sq_idx = $sqrow->uidx;
#[[
			$c->log->debug("ADD LINK SQ-KT: <[SQ: ".$sq_idx."]><[SB: ".$sb_idx."]>");
#]]
			foreach $ktrow (@ktprogs) {

				### handle also filter here ###

				### add 
				$row = $m->create( { sq_idx => $sq_idx, kt_idx => $ktrow, inherited => 1 } );
#[[
				$c->log->debug(">>>>>>>> +KT ".$ktrow);
#]]
			}
		}
	}
}

# DELETE
sub sqsbext_delete_kanaltabelle {
	my ( $self, $c, $sq_idx, $sb_idx ) = @_;
	my ( $m, $rs );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sqsbext_delete_kanaltabelle /sq_idx $sq_idx, pg_idx $sb_idx/ - [ $info ]");
#]]

	# pickup the model for this controller
	$m = $c->model('katamaDB::kanaltabelle');

	$rs = $m->search( { 'me.sq_idx' => $sq_idx, 'me.sb_idx' => $sb_idx } );
#[[
#	my $row;
#	$c->log->debug("CASCADE DELETE KT: <[SQ: ".$sq_idx."]><[SB: ".$sb_idx."]>");
#	foreach $row ( @rs ) {
#		$c->log->debug(">>>>>> KT <[".$row->uidx."]> Programm ID <[".$row->pg_idx."]>");
#	}
#]]
	$rs->delete;

#[[
	$c->log->debug("DELETED!");
#]]
	return $self->status_ok( $c,
		entity => { sqid => $sq_idx, sbid => $sb_idx } );
}

# END #

1;
