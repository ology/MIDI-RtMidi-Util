package MIDI::RtMidi::Util;

# ABSTRACT: Handy Utilities for Real-time MIDI

our $VERSION = '0.0502';

use v5.40;
# use Data::Dumper::Compact qw(ddc);
use MIDI::RtMidi::FFI::Device ();
use Exporter 'import';

our @EXPORT = qw(
    in_port
    out_port
    stop_device
    input_ports
    output_ports
    stop_all_notes
    program_changer
);

=head1 SYNOPSIS

  use MIDI::RtMidi::Util qw(
    input_ports output_ports in_port out_port stop_device stop_all_notes
  );

  my $ports = input_ports(); # e.g. ['USB MIDI Interface', ...]
  $ports = output_ports();

  my $midi_in  = in_port('keyboard');
  my $midi_out = out_port('usb');
  # Do something cool ...

  END {
    stop_device($midi_out);
    stop_all_notes($midi_out);
  }

=head1 DESCRIPTION

C<MIDI::RtMidi::Util> is a junk drawer for real-time MIDI utilities.

=head1 FUNCTIONS

=head2 in_port

  $in_port = in_port($name);

Open and return a named L<MIDI::RtMidi::FFI::Device> C<RtMidiIn> device.

This function takes a unique part of an open MIDI port name as its argument.

=cut

sub in_port ($name) {
    my $midi_in = RtMidiIn->new;
    try { $midi_in->open_port_by_name(qr/\Q$name/i) }
    catch ($e) { die "Can't open MIDI port: $name\n" }
    return $midi_in;
}

=head2 out_port

  $out_port = out_port($name);

Open and return a named L<MIDI::RtMidi::FFI::Device> C<RtMidiOut> device.

This function takes a unique part of an open MIDI port name as its argument.

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

=head2 stop_device

  stop_device($device);

Stop an open C<MIDI::RtMidi::FFI::Device> device.

=cut

sub stop_device ($device) {
    try {
        $device->stop;
        $device->panic;
    }
    catch ($e) {
        chomp $e;
        warn "Can't stop the MIDI device: $e\n";
    }
}

=head2 stop_all_notes

  stop_all_notes($device);

Send a C<note_off()> message to all 16 channels and all 128 notes.

=cut

sub stop_all_notes ($device) {
    for my $chan (0 .. 15) {
        for my $n (0 .. 127) {
            $device->note_off($chan, $n, 0);
        }
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

=head2 program_changer

  program_changer($device, $program, $channel, $msb_bank, $lsb_bank);

Send bank select messages (CC#0 MSB and CC#32 LSB when given) followed by a
C<program_change> message. The C<program> and C<channel> arguments default to
C<0>. The C<msb_bank> and C<lsb_bank> arguments default to C<undef>.

Note that some devices B<remember> the C<lsb_bank> and so, in order for the
C<program_change> message to be recognized the C<lsb_bank> must be changed from
the previous setting.

=cut

sub program_changer ($device, $program=0, $channel=0, $msb_bank=undef, $lsb_bank=undef) {
    try {
        if (defined $msb_bank || defined $lsb_bank) {
            $device->control_change($channel, 0, $msb_bank // 0);
            $device->control_change($channel, 32, $lsb_bank // 0);
        }
        $device->program_change($channel, $program);
    }
    catch ($e) {
        # BUGFIX: errors usually end in a newline already; avoid a doubled one.
        chomp $e;
        die "ERROR: $e\n";
    }
}

1;
__END__

=head1 SEE ALSO

L<MIDI::RtMidi::FFI::Device>

=cut
