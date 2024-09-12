#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katama::Common;

use strict;
use warnings;
use Switch;

=head1 NAME

=head1 DESCRIPTION

=head1 METHODS

=cut

=head1 AUTHOR

sim,,,

=head1 LICENSE

=cut


=head2 list

=cut


### locking functions ###

sub lock_app {
	my ($c, $maxwait) = @_;
	my ($rs) = $c->model('GetLock')->search({}, { bind => [$maxwait] });
#[[
	$c->log->debug("GETLOCK: ".$rs->ret);
#]]
	return $rs->ret;
}


sub unlock_app {
	my ($c) = @_;
	my ($rs) = $c->model('UnLock')->search({});
#[[
	$c->log->debug("UNLOCK: ".$rs->ret);
#]]
	return $rs->ret;
}


### signalquelle helpers ###

sub sq_getallkids {
	my($c, $parent) = @_;

	my($rs) = $c->model('preGetAllKids')->search({}, { bind => [$parent] });
#[[
	$c->log->debug("preGetAllKids KIDS FOUND:".$rs->ret);
#]]
	return $rs->ret;
}


sub sb_add_sqsb_programm {
	my ($self, $c, $sb_idx, $pg_idx) = @_;
#[[
	$c->log->debug("sb_add_sqsb_programm ---> SB: ".$sb_idx." PG: ".$pg_idx);
#]]

}


sub sb_delete_sqsb_programm {
	my ($self, $c, $sb_idx, $pg_idx) = @_;
#[[
	$c->log->debug("sb_delete_sqsb_programm ---> SB: ".$sb_idx." PG: ".$pg_idx);
#]]

}


### mapping functions ###

sub get_pgtype {
	my $pg_type = shift @_;
	my @pg_types = ( 'TV', 'Radio', 'Bouquet', 'Daten' );
	return ($pg_types[$pg_type - 1]);
}

sub get_sbtype {
	my $pg_type = shift @_;
	my @pg_types = ( 'Satellit', 'Kabel', 'Terrestrisch' );
	return ($pg_types[$pg_type - 1]);
}


1;
