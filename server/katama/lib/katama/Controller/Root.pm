#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katama::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

katama::Controller::Root - Root Controller for katama

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
	my ( $self, $c ) = @_;
	$c->response->body( "<html><body>KTM-2 Service</body></html>" );
#	$c->stash->{ 'template' } = 'index.tt2';
}

=head2 index

=cut

#sub index : Private {
#	my ( $self, $c ) = @_;
#	$c->response->body( "<html><body>KTM-2 Service</body></html>" );
#	$c->stash->{ 'template' } = 'index.tt2';
#}

=head2 end

Attempt to render a view, if needed.

=cut 

# this is required only if we use some proper view
#sub end : ActionClass('RenderView') {}
#sub end : ActionClass('Serialize') {}

=head1 AUTHOR

sim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
