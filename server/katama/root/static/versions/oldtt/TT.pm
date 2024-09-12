#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katama::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    CATALYST_VAR => 'Catalyst',
    INCLUDE_PATH => [
        katama->path_to( 'root', 'src' ),
        katama->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
#	DEBUG        => 'undef',
#	DEBUG		 => 'dirs',
#	DEBUG_FORMAT => '<!-- $file line $line: [% $text %] -->',
    TIMER        => 0
});

=head1 NAME

katama::View::TT - Catalyst TTSite View

=head1 SYNOPSIS

See L<katama>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

sim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

