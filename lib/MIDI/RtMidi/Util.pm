package MIDI::RtMidi::Util;

# ABSTRACT: Handy Utilities for Real-time MIDI

our $VERSION = '0.0100';

use v5.36;
use feature 'try';

# use Data::Dumper::Compact qw(ddc);
use MIDI::RtMidi::FFI::Device ();
use Exporter 'import';
our @EXPORT = qw(
    out_port
    halt
);

no warnings 'experimental::try';

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
    say ddc $midi_out;
    try { $midi_out->open_virtual_port('RtMidiOut') } # needed for mac
    catch ($e) {
        # warn 'Not a Mac';
    }
    try { $midi_out->open_port_by_name(qr/\Q$name/i) }
    catch ($e) { die "Can't open MIDI port: $name\n" }
    return $midi_out;
}

=head2 halt

  halt();

Stop and close an open C<RtMidiOut> device.

=cut

sub halt ($midi_out) {
    try {
        $midi_out->stop;
        $midi_out->panic;
    }
    catch ($e) {
        warn "Can't halt the MIDI out devices: $e\n";
    }
    exit;
}

1;
__END__

=head1 SEE ALSO

L<MIDI::RtMidi::FFI::Device>

=cut
