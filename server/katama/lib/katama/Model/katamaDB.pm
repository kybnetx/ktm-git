#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katama::Model::katamaDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'katamaDB',
    connect_info => [
        'dbi:mysql:ktmanager',
        'ktmanager',
        'ktmanager',
        { AutoCommit => 1 },
		{ on_connect_do => [ 'SET character_set_client = utf8' ] }
	],
);

=head1 NAME

katama::Model::katamaDB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<katama>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<katamaDB>

=head1 AUTHOR

sim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
