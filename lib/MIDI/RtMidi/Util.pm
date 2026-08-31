package MIDI::RtMidi::Util;

# ABSTRACT: Handy Utilities for Real-time MIDI

our $VERSION = '0.0100';

use v5.36;

use MIDI::RtMidi::FFI::Device ();

=head1 SYNOPSIS

  use MIDI::RtMidi::Util qw(out_port);

  my $out_port = out_port('usb');

=head1 DESCRIPTION

C<MIDI::RtMidi::Util> is a junk drawer for Real-time MIDI utilities.

=cut

=head1 FUNCTIONS

=head2 out_port

  $out_port = out_port($name);

Open and return a L<MIDI::RtMidi::FFI::Device> C<RtMidiOut> device.

=cut

sub out_port ($name) {
    my $midi_out = RtMidiOut->new;
    try { $midi_out->open_virtual_port('RtMidiOut') } # needed for mac
    catch ($e) {
        # warn 'Not a Mac';
    }
    try { $midi_out->open_port_by_name(qr/\Q$name/i) }
    catch ($e) { die "Can't open MIDI port: $name\n" }
    return $midi_out;
}

1;
__END__

=head1 SEE ALSO

L<MIDI::RtMidi::FFI::Device>

=cut
