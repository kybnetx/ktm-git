package Catalyst::Action::Serialize::JSONXS;

use strict;
use warnings;

use base 'Catalyst::Action';
use JSON::XS;

sub execute {
    my $self = shift;
    my ( $controller, $c ) = @_;

    my $stash_key = (
            $controller->config->{'serialize'} ?
                $controller->config->{'serialize'}->{'stash_key'} :
                $controller->config->{'stash_key'} 
        ) || 'rest';
    my $output;
    eval {
		$output = JSON::XS->new->encode($c->stash->{$stash_key});
    };
    if ($@) {
        return $@;
    }
    $c->response->output( $output );
    return 1;
}

1;
