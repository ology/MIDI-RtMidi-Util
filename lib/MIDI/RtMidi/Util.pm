package MIDI::RtMidi::Util;

# ABSTRACT: Handy Utilities for Real-time MIDI

our $VERSION = '0.0100';

use strict;
use warnings;

=head1 SYNOPSIS

  use MIDI::RtMidi::Util ();

  $foo = MIDI::RtMidi::Util::foo();

=head1 DESCRIPTION

C<MIDI::RtMidi::Util> is a container for Real-time MIDI utilities.

=cut

=head1 FUNCTIONS

=head2 foo

  $foo = MIDI::RtMidi::Util::foo();

Foo!

=cut

sub foo {
    my (%args) = @_;
    my $foo ||= 'bar';
    return $foo;
}

1;
__END__

=head1 SEE ALSO

L<Another::Module>

=cut
