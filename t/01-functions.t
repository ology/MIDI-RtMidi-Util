#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

use_ok 'MIDI::RtMidi::Util';

lives_ok { MIDI::RtMidi::Util::foo(666) }
    'lives through foo()';

done_testing();
