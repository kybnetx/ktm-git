#// vim: ts=4:sw=4:nu:fdc=1:nospell

#
# Cut'n'Replace Class for RESTy games
#
# 1. Combodata - name of this controller
# 2. cbd - table abbreviation for mapping functions
# 4. combox - application DB model for REST interface
# 5. cbselect - actions of REST interface
# 6. cbext - path to access actions of REST interface
#


package katama::Controller::Combodata;

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

	$c->response->body('Matched katama::Controller::Combodata');
}


=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


sub get_cbd {
	my $row = shift;
	my %e = (
		val => $row->value,
		ds1 => $row->display1
	);
	$e{abb} = $row->abbr if ($row->abbr);
	$e{ds2} = $row->display2 if ($row->display2);
	return \%e
}


#########  combox  #########

### ALL (no args) ###
sub cbselect : Path('/cbext') : Args(1) : ActionClass('REST') {
	my ( $self, $c, $cbid ) = @_;
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: cbselect_all [ $info - $cbid ]");
#]]
}

# GET
sub cbselect_GET  {
	my ( $self, $c, $cbid ) = @_;
	my ( $m, @rowobjs, $row, %data );
#[[
	my $info = $c->request->content_type;
	$c->log->debug("###### DEBUGGE: cbselect_all_GET [ $info - $cbid ]");
#]]

	# pickup the model for this controler
	$m = $c->model('katamaDB::combox');

	# pickup all records
	@rowobjs = $m->search( { cbname => $cbid } );

	if ( ! @rowobjs ) {
		return $self->status_not_found( $c,
			message => "GET_notfound" );
	}

	# map result row into JSON data array
	$data{'cbd'} = ();
	for $row ( @rowobjs ) {
		push( @{ $data{'cbd'} }, get_cbd($row) );
	}

	# return result set
	return $self->status_ok( $c, entity => \%data);
}

# END #########  combox  #########


1;
