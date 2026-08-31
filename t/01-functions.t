#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
    use_ok 'MIDI::RtMidi::Util', qw(out_port halt);
}

subtest throws => sub {
    throws_ok { out_port() }
        qr/Too few arguments/,
        'out_port() dies without port name';
    throws_ok { halt() }
        qr/Too few arguments/,
        'halt() dies without port';
};

done_testing();
