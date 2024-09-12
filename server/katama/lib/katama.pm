#// vim: ts=4:sw=4:nu:fdc=1:nospell

package katama;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

use Catalyst qw/-Debug ConfigLoader Static::Simple StackTrace Redirect Unicode/;

our $VERSION = '0.66';

# Configure the application. 
#
# Note that settings in katama.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config( name => 'katama' );

# Start the application
__PACKAGE__->setup;


=head1 NAME

katama - Catalyst based application

=head1 SYNOPSIS

    script/katama_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<katama::Controller::Root>, L<Catalyst>

=head1 AUTHOR

sim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
