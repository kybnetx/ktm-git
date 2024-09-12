package Catalyst::Action::Deserialize::JSONXS;

use strict;
use warnings;

use base 'Catalyst::Action';
use JSON::XS;

sub execute {
    my $self = shift;
    my ( $controller, $c, $test ) = @_;

    my $body = $c->request->body;
    my $rbody;

    if ($body) {
        while (my $line = <$body>) {
            $rbody .= $line;
        }
    }

    if ( $rbody ) {
        my $rdata = eval { JSON::XS->new->utf8->decode( $rbody ); };
        if ($@) {
            return $@;
        }
        $c->request->data($rdata);
    } else {
        $c->log->debug(
            'I would have deserialized, but there was nothing in the body!')
            if $c->debug;
    }
    return 1;
}

1;
