package MIDI::RtMidi::Util;

# ABSTRACT: Handy Utilities for Real-time MIDI

our $VERSION = '0.0200';

use v5.36;
use feature 'try';

# use Data::Dumper::Compact qw(ddc);
use MIDI::RtMidi::FFI::Device ();
use Exporter 'import';
our @EXPORT = qw(
    out_port
    halt
    input_ports
    output_ports
);

no warnings 'experimental::try';

=head1 SYNOPSIS

  use MIDI::RtMidi::Util qw(out_port halt input_ports output_ports);
  use POSIX qw(_exit); # skips global destruction

  my $ports = input_ports(); # e.g. ['USB MIDI Interface', ...]
  $ports = output_ports();

  my $midi_out = out_port('usb');

  END {
    halt($midi_out);
  }
  # or redefine what happens on ^C:
  $SIG{INT} = sub {
    say "\nStop";
    halt($midi_out);
    _exit(0);
  };

=head1 DESCRIPTION

C<MIDI::RtMidi::Util> is a junk drawer for Real-time MIDI utilities.

=cut

=head1 FUNCTIONS

=head2 out_port

  $out_port = out_port($name);

Open and return a named L<MIDI::RtMidi::FFI::Device> C<RtMidiOut> device.

This function takes a unique part of an open port name as its argument.

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
}

=head2 input_ports

  $input_ports = input_ports();

Return an array-reference of open MIDI input port names.

=cut

sub input_ports () {
    my $device = RtMidiIn->new;
    return [
        map { $device->get_port_name($_) }
            sort { $a <=> $b } keys $device->get_all_port_nums->%*
    ];
}

=head2 output_ports

  $output_ports = output_ports();

Return an array-reference of open MIDI output port names.

=cut

sub output_ports () {
    my $device = RtMidiOut->new;
    return [
        map { $device->get_port_name($_) }
            sort { $a <=> $b } keys $device->get_all_port_nums->%*
    ];
}

1;
__END__

=head1 SEE ALSO

L<MIDI::RtMidi::FFI::Device>

=cut
