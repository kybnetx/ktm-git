use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'katama' }
BEGIN { use_ok 'katama::Controller::Bookings' }

ok( request('/bookings')->is_success, 'Request should succeed' );


