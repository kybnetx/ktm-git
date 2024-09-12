#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1.  SBProvider - name of this controller
# 2.  sbp - table abbreviation for mapping functions
# 4.  sbprovider - application DB model for REST interface
# 5.  sbpext_grid - actions of REST interface
# 6.  sbpext - path to access actions of REST interface
#


package katama::Controller::SBProvider;

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

	$c->response->body('Matched katama::Controller::SBProvider');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


sub get_sbp {
	my $row = shift;
	my %e = (
		uidx => $row->uidx,
# ----------------------------------
		nam => $row->name,
		frm => $row->firma,
		ver => $row->vertrag,
		kt1 => $row->kontakt1,
		kt2 => $row->kontakt2,
		lnd => $row->land,
		eml => $row->email,
		www => $row->www,
		isk => $row->iskabprov
	);
	return \%e
}


#########  SBProvider  #########

### SINGLE ( arg1 == uidx ) ###

sub sbpext_grid : Path('/sbpext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $uidx ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sbpext_grid /UIDX $uidx/ - [ $info ]");
#]]
}

# GET
sub sbpext_grid_GET  {
	my ( $self, $c, $uidx ) = @_;
	my ( $m, $row, %data );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sbpext_grid_GET /UIDX $uidx/ - [ $info ]");
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
	$m = $c->model('katamaDB::sbprovider');

	# find record we are looking for
	$row = $m->find( $uidx );

#	if ( !defined($row) ) {
	if ( !defined($row) ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# map result row into JSON data array
	$data{'sbp'} = [ get_sbp($row) ];

	# return result set
	return $self->status_ok( $c, entity => \%data);
}


### SELECTION GRID ###

sub get_sbpsel {
	my $row = shift;
	my %e = (
		uidx => $row->uidx,
		nam => $row->name,
		frm => $row->firma,
		lnd => $row->land
	);
	return \%e
}

### ALL (no args) ###
sub sbpext_grid_sel : Path('/sbpext_sel') : Args(0) : ActionClass('REST') {
	my ( $self, $c ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sbpext_grid_sel [ $info ]");
#]]
}

# GET
sub sbpext_grid_sel_GET  {
	my ( $self, $c ) = @_;
	my ( $m, @rowobjs, $row, %data );

#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: sbpext_grid_sel_GET [ $info ]");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::sbprovider');

	# pickup all records
	@rowobjs = $m->search( uidx => { '>', 0 } );

	if ( ! @rowobjs ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# map result row into JSON data array
	$data{'sbpsel'} = ();
	for $row ( @rowobjs ) {
		push( @{ $data{'sbpsel'} }, get_sbpsel($row) );
	}

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

### POST - PAGING METHOD OF EXT
sub sbpext_grid_sel_POST {
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
	$c->log->debug("###### DEBUGGE: sbpext_grid_sel_POST [ $info ]");
	$c->log->debug("###### /START: $start/ - /LIMIT: $limit/");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::sbprovider');

	# get the total row count of the dataset
	$rowscount = $m->count( uidx => { '>', 0 } );

	# pickup requested records
	@rowobjs = $m->search( { uidx => { '>', 0 } }, { 'rows' => $limit, 'page' => ($start/$limit + 1) } );

	if ( ! @rowobjs ) {
		return $self->status_not_found( $c,
			message => "POST_notfound" );
	}

	# map result row into JSON data array
	$data{'sbpsel'} = ();
	for $row ( @rowobjs ) {
		push( @{ $data{'sbpsel'} }, get_sbpsel($row) );
	}

	# the total number of rows for pager
	$data{'count'} = $rowscount;

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

# END #########  SBProvider  #########


1;
