#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katama::Controller::Signalquellen;

use strict;
use warnings;
use katama::Common;
use JSON::XS;

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

	$c->response->body('Matched katama::Controller::Signalquellen');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut



=head2 list

=cut


sub set_co {
	my $new = shift;
	my %n;
# node attributes 'contactoffice':
	$n{'firma'} = $new->{cfr} if($new->{cfr});
	$n{'kontakt'} = $new->{ckn} if($new->{ckn});
	$n{'telefon'} = $new->{ctl} if($new->{ctl});
	$n{'fax'} = $new->{cfx} if($new->{cfx});
	$n{'strasse'} = $new->{cst} if($new->{cst});
	$n{'hausnr'} = $new->{chn} if($new->{chn});
	$n{'hausnrzus'} = $new->{chz} if($new->{chz});
	$n{'plz'} = $new->{cpl} if($new->{cpl});
	$n{'ort'} = $new->{cor} if($new->{cor});
	return \%n
}


sub set_sq {
	my $new = shift;
	my %n = (
		strasse => $new->{sst},
		hausnr => $new->{shn},
		hausnrzus => $new->{shz},
		plz => $new->{spl},
		ort => $new->{sor},
		land => $new->{sld},
		region => $new->{srg},
		sumwe => $new->{ssw},
		wesoll => $new->{sws},
		netzid => $new->{snd},
		sq_type => $new->{stp},
		dataorigin => $new->{sdo}
	);
	return \%n
}


sub get_sq_co {
	my $sq = shift;
	my $co = $sq->b2_co;
	my %e = (
# node properties
		id => $sq->uidx,
# node attributes 'signalquelle':
		stl => $sq->tlevel,
		ssw => $sq->sumwe,
		sws => $sq->wesoll,
		snd => $sq->netzid,
		stp => $sq->sq_type,
		sdo => $sq->dataorigin,
		sst => $sq->strasse,
		shn => $sq->hausnr,
		shz => $sq->hausnrzus,
		spl => $sq->plz,
		sor => $sq->ort,
		sld => $sq->land,
		srg => $sq->region,
# node attributes 'contactoffice':
		cfr => $co->firma,
		ckn => $co->kontakt,
		ctl => $co->telefon,
		cfx => $co->fax,
		cst => $co->strasse,
		chn => $co->hausnr,
		chz => $co->hausnrzus,
		cpl => $co->plz,
		cor => $co->ort
	);
# important to stop diving
	$e{'leaf'} = 'true' if ($sq->sqh_sq->count == 0);
	return \%e;
}


sub load_sqkids {
	my ( $c, $uidx ) = @_;
	my %tsr;

	# find out who is the dady
	my $dad = $c->model('katamaDB::signalquelle')->find($uidx);

	if (! defined($dad) ) {
		return undef;
	}

	%tsr = ( 'me.sq_idx' => $uidx, 'me.uidx' => { '>', 0 } );

	my $rs = $c->model('katamaDB::signalquelle')->search
	(
		 \%tsr
		,{
			join => [qw/ b2_co sqh_sq /],
			prefetch => [qw/ b2_co sqh_sq /],
			order_by => [qw/ tlevel tidx0 tidx1 tidx2 tidx3 /]
		}
	);

	my @sqrows = ();
	while (my $row = $rs->next ) {
		push( @sqrows, get_sq_co($row) );
	}

	return ($#sqrows >= 0 ? \@sqrows : undef);
}


sub cascade_json_obj {
	my ( $c, $obj, $par ) = @_;
	my ( $id );

	foreach $id ( keys %$obj ) {
#[[
		$c->log->debug(">>> Node $par.$id expanded >>>");
#]]
		if( $obj->{$id} != 1) {
			cascade_json_obj( $c, $obj->{$id}, $par.'.'.$id );
		}
	}
}


### load_expanded_sq ###
sub load_expanded_sq {
	my ( $c, $uidx, $exp ) = @_;

	cascade_json_obj( $c, $exp, $uidx);

	return( load_sqkids($c, $uidx) );
}


### sqsingle #########

sub sqsingle : Path('/sq') : Args(1) : ActionClass('REST') {
}

sub sqsingle_GET {
	my ( $self, $c, $uidx ) = @_;

	my $rs = $c->model('katamaDB::signalquelle')->search
	(
		{
			'me.uidx' => $uidx
		}, {
			join => [qw/ b2_co /],
			prefetch => [qw/ b2_co /]
		}
	);

	my $row = $rs->next;

	if ( defined($row) ) {
		my %sqrows = ();
		push( @{ $sqrows{'sqsingle'} }, get_sq_co($row) );
		$self->status_ok(
			$c,
			entity => \%sqrows
		);
	}
	else {
		$self->status_not_found( $c, message => "GET /sq/$uidx : ID not found." );
	}
}


#########  Signalquellen Controller  #########

sub sqext_tree : Path('/sqext') : Args(0) : ActionClass('REST') {
	my ( $self, $c ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### MOJ DEBUGGE: $info");
#]]
}

### GET - query UNEXPANDED childern of the node ###
sub sqext_tree_GET {
	my ( $self, $c ) = @_;
	my ( $data, $uidx );

	$uidx = $c->request->param('node');

	if( !defined($uidx) ) {
		# node not supplied
		return $self->status_bad_request( $c,
			message => "GET_sqext_keymissing" );
	}

#[[
	$c->log->debug(" >>> uidx: >>> $uidx");
#]]

	$data = load_sqkids($c, $uidx);

	# check for empty array-resultset or count = $#{ $sq }
	if ( !defined($data) ) {
		# node not found
		return $self->status_not_found( $c,
			message => "GET_sqext_notfound" );
	}

	# fine, we've got result set to GET
	return $self->status_ok( $c, entity => $data );
}

### POST - query EXPANDED STATE children of the node ###
sub sqext_tree_POST {
	my ( $self, $c ) = @_;
	my ( $data, $uidx, $expand );

	$uidx = $c->request->param('node');
	$expand = $c->request->param('expand');

	if( !defined($uidx) || !defined($expand) ) {
		# node not supplied
		return $self->status_bad_request( $c,
			message => "POST_sqext_paramissing" );
	}

#[[
	$c->log->debug(" >>> uidx: >>> $uidx");
	$c->log->debug(" >>> expand: >>> $expand");
#]]

	$data = load_expanded_sq($c, $uidx, JSON::XS->new->decode( $expand ) );

	# check for empty array-resultset or count = $#{ $sq }
	if ( !defined($data) ) {
		# node not found
		return $self->status_not_found( $c,
			message => "POST_sqext_notfound" );
	}

	# fine, we've got result set to POST
	return $self->status_ok( $c, entity => $data );
}

##############################################################################
##############################################################################

#########  sqkext_tree  #########

sub sqkext_tree : Path('/sqkext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $nodeid ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### MOJ DEBUGGE: $info");
	$c->log->debug("---------------- Arg[1]:  $nodeid");
#]]
}


sub sqkext_tree_GET {
	my ( $self, $c, $uidx ) = @_;

	if( !defined($uidx) ) {
		# node not supplied
		return $self->status_bad_request( $c,
			message => "GET_sqkext_keymissing" );
	}

#[[
	$c->log->debug("================ uidx:> $uidx");
#]]

	my $sq = load_sqkids($c, $uidx);

	# check for empty array-resultset or count = $#{ $sq }
	if ( !defined($sq) ) {
		# node not found
		return $self->status_not_found( $c,
			message => "GET_sqkext_notfound" );
	}

	# fine, we've got result set to GET
	return $self->status_ok( $c, entity => $sq);
}


sub sqkext_tree_POST {
    my ( $self, $c, $uidx ) = @_;
	my ( $data, $rowobj, $rec, $rs );

#[[
	$c->log->debug("WAS HERE in THE sqkext_tree_POST");
#]]

	if (!defined($uidx)) {
		return $self->status_bad_request( $c,
			message => "POST_sqkext_keymissing" );
	}

	$data = $c->req->data;

	if (!defined($data)) {
		return $self->status_bad_request( $c,
			message => "POST_sqkext_datamissing" );
	}

#[[
	my $key;
	foreach $key ( keys %$data ) {
		$c->log->debug("Key $key => ".$data->{$key});
	}
#]]
	$rec = set_sq($data);

	### insert node on the same level or on the parent level
	### currently only parent level active
	if( $uidx == 0 ) {
		$rec->{sq_idx} = ($data->{ulv} eq '1' ? $data->{sqcid} : $data->{sqpid});
		### important for tree order
		$rec->{ptemp} = $data->{prev};
	}
#[[
	foreach $key ( keys %$rec) {
		$c->log->debug("Setting Key $key => ".$rec->{$key});
	}
#]]

	$rs = $c->model('katamaDB::signalquelle');

	# lock application transaction to properly get last uidx and send messages
	if ( katama::Common::lock_app($c, 15) ) {

		### CREATE ###

		if( $uidx == 0 ) {

			$rowobj = $rs->create( $rec );

			# find out the index of new record
			$uidx = $rowobj->uidx;

			sqext_create_inherited_kt($self, $c, $rowobj->sq_idx, $uidx);

			katama::Common::unlock_app($c);
#[[
			$c->log->debug("uidx: $uidx - CREATE returned ".$rowobj);
#]]
			return $self->status_created( $c,
				location => $c->req->uri->as_string,
				entity => { uidx => $uidx } );
		}

		### UPDATE ###

		else {
			# locking does not make much sense for update as InnoDB is atomic. but
			# need some message mechanism to mark records as dirty until all clients
			# get updated with new information. need some queue for dirty things.
			# or we just send updating client dirty error with new data (1/2 solution
			# which does not update client view. need some hydra mechanics here.)
			$rowobj = $rs->find( $uidx );
			if ( defined($rowobj) ) {

				$rowobj->update( $rec );

				katama::Common::unlock_app($c);
#[[
				$c->log->debug("uidx: $uidx - UPDATE returned ".$rowobj);
#]]
				return $self->status_ok( $c, entity => { uidx => $uidx } );

			} else {
				# node not found
				katama::Common::unlock_app($c);
				return $self->status_not_found( $c,
					message => "UPDATE_sqkext_notfound" );
			}
		}
	}
	else {
		# HANDLE LOCK ERROR HERE
	}
}


sub sqkext_tree_DELETE {
	my ( $self, $c, $uidx ) = @_;
	my ( $rowobj );

#[[
	$c->log->debug("WAS HERE in THE sqkext_tree_DELETE uidx: ".$uidx);
#]]

	if( !defined($uidx) ) {
		# node not supplied
		return $self->status_bad_request( $c,
			message => "DELETE_sqkext_keymissing" );
	}

	if ( katama::Common::lock_app($c, 15) ) {
		$rowobj = $c->model('katamaDB::signalquelle')->find($uidx);

		if ( !defined($rowobj) ) {
			katama::Common::unlock_app($c);
			# node not found
			return $self->status_not_found( $c,
				message => "DELETE_sqkext_notfound" );
		}

		$rowobj->delete;

		katama::Common::unlock_app($c);
		return $self->status_ok( $c, entity => { uidx => $rowobj->uidx } );
	}
}

###############################################################################
### CREATE AND DELETE KANALTABELLE FOR NEW SQ (INHERIT PARENT KT)
###############################################################################


sub sqext_create_inherited_kt {
	my ($self, $c, $sqparent, $sq_idx) = @_;
	my ($m, $row, $ktrow, @ktprogs);

	# pickup connector model
	$m = $c->model('katamaDB::signalquellenkanal');

	# get programms of that SB	
	@ktprogs = $m->search( { 'me.sq_idx' => $sqparent } ) or return;

	foreach $ktrow (@ktprogs) {

		### handle also filter here ###

		### add 
		$row = $m->create( { sq_idx => $sq_idx, kt_idx => $ktrow->kt_idx, inherited => 1 } );
#[[
		$c->log->debug(">>>>>>>> +KT ".$ktrow->kt_idx);
#]]
	}
}

1;
