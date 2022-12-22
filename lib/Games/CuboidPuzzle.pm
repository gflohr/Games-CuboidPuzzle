#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

# This next lines is here to make Dist::Zilla happy.
# ABSTRACT: A Perl Representation of cuboid puzzles like the Rubik's Cube

package Games::CuboidPuzzle;

use strict;
use v5.10;

use Locale::TextDomain qw(1.32);

my %defaults = (
	xwidth => 3,
	ywidth => 3,
	zwidth => 3,
	colors => [qw(G O W R Y B)],
);

sub new {
	my ($class, %args) = @_;

	my $self = {};
	bless $self, $class;

	foreach my $key (keys %defaults) {
		$self->{'__' . $key} = $args{$key} // $defaults{$key};
	}

	if (@{$self->{__colors}} != 6) {
		require Carp;
		Carp::croak(__"exactly 6 colors required")
	}

	my %colors = map { $_ => 1 } @{$self->{__colors}};
	if (keys %colors != 6) {
		require Carp;
		Carp::croak(__"colors must be unique")
	}

	my @dim_keys = qw(__xwidth __ywidth __zwidth);
	my @dims = @{$self}{@dim_keys};
	foreach my $i (0 .. $#dim_keys) {
		my $dim = $dims[$i];
		if ($dim !~ /^[1-9][0-9]*$/) {
			my $key = $dim_keys[$i];
			require Carp;
			Carp::croak(__x("invalid value '{value}' for '{param}'",
				value => $dim, param => $key));
		}
	}

	$self->__setup if !exists $self->{__state};

	my $num_stickers = (
		$dims[0] * $dims[1]
		+ $dims[0] * $dims[2]
		+ $dims[1] * $dims[2]) << 1;
	if ($num_stickers != @{$self->{__state}}) {
		require Carp;
		Carp::croak(__x("cube must have {wanted}, not {got} stickers",
			wanted => $num_stickers, got => scalar @{$self->{__state}}));
	}

	$self->__setupMoves;

	return $self;
}

sub __setupMoves {
	my ($self) = @_;

	$self->{__shifts} = [[], [], []];

	$self->__setupXMoves;
}

sub __setupXMoves {
	my ($self) = @_;

	my $layer_index = 0;

	my $xw = $self->{__xwidth};
	my $yw = $self->{__ywidth};
	my $zw = $self->{__zwidth};

	my $single_turns = $yw == $zw;
	foreach my $x (0 .. $xw - 1) {
		my @cycles;
		foreach my $z (0 .. $zw - 1) {
			# Each cycle consists of 4 elements.  If single turns are not
			# possible, elements #1 and #3 are invalid but unused.
			my @cycle = ($x + $z * $xw);
			push @cycle, $xw * $zw + $z * 2 * ($zw + $xw) + $zw + $x;
			push @cycle, $xw * $zw + $yw * 2 * ($zw + $xw) + $z * $xw + $x;
			push @cycle, $xw * $zw + ($yw - $z) * 2 * ($zw + $xw) - $x - 1;
			push @cycles, \@cycle;
		}
		if ($x == 0) {
			# Rotate adjacent layer next to origin.
			my @layer;
			my $offset = $xw * $zw;
			foreach my $y1 (0 .. $yw - 1) {
				my @row;
				foreach my $x1 (0 .. $zw - 1) {
					push @row, $offset + $y1 * 2 * ($zw + $xw) + $x1;
				}
				push @layer, \@row;
			}
			push @cycles, $self->__rotateLayer(\@layer);
		} elsif ($x == $xw - 1) {
			# Rotate adjacent layer far from origin.
			my @layer;
			my $offset = $xw * $zw + $zw + $xw;
			foreach my $y1 (0 .. $yw - 1) {
				my @row;
				foreach my $x1 (0 .. $zw - 1) {
					# We use the reverse order for the rows so that we need
					# just one layer cycling algorithm.
					unshift @row, $offset + $y1 * 2 * ($zw + $xw) + $x1;
				}
				push @layer, \@row;
			}
			push @cycles, $self->__rotateLayer(\@layer);			
		}

		my @from;
		foreach my $cycle (@cycles) {
			push @from, @$cycle;
		}
		$self->{__shifts}->[$layer_index]->[$x + 1]->[0] = \@from;
		foreach my $turns (1 .. 3) {
			next if $turns != 2 && !$single_turns;

			my @to;
			foreach my $cycle (@cycles) {
				foreach my $i (0 .. 3) {
					push @to, $cycle->[($i + $turns) & 0x3];
				}
			}

			$self->{__shifts}->[$layer_index]->[$x + 1]->[$turns] = \@to;
		}
	}

	return $self;
}

sub __rotateLayer {
	my ($self, $layer) = @_;

	my $max_row = @{$layer} - 1;
	my $max_col = @{$layer->[0]} - 1;

	my @cycles;
	my $has_centre = $max_row == $max_col && !($max_row & 1);
	foreach my $rowno (0 .. $max_row) {
		foreach my $colno (0 .. $max_col) {
			next if $has_centre && $rowno == $max_row >> 1 && $rowno == $colno;
			next if !defined $layer->[$rowno]->[$colno];
			my @cycle;
			push @cycle, $layer->[$rowno]->[$colno];
			undef $layer->[$rowno]->[$colno];
			if ($max_row == $max_col) {
				push @cycle, $layer->[$colno]->[$max_col - $rowno];
				undef $layer->[$colno]->[$max_col - $rowno];
			} else {
				push @cycle, undef;
			}
			push @cycle, $layer->[$max_row - $rowno]->[$max_col - $colno];
			undef $layer->[$max_row - $rowno]->[$max_col - $colno];
			if ($max_row == $max_col) {
				push @cycle, $layer->[$max_row - $colno]->[$rowno];
				undef $layer->[$max_row - $colno]->[$rowno];
			}
			push @cycles, \@cycle;
		}
	}

	return @cycles;
}

sub __setup {
	my ($self) = @_;

	my @state;
	$self->{__state} = \@state;

	my @dim_keys = qw(__xwidth __ywidth __zwidth);
	my ($x, $y, $z) = @{$self}{@dim_keys};

	# First side (green).
	@state[0 .. $x * $z - 1] = map { $self->{__colors}->[0] } (1 .. $x * $z);

	# Second side (orange).
	foreach (my $row = 0; $row < $y; ++$row) {
		foreach (my $col = 0; $col < $z; ++$col) {
			my $offset = $x * $z
				+ $row * ($z + $x) * 2
				+ $col;
			$state[$offset] = $self->{__colors}->[1];
		}
	}

	# Third side (white).
	foreach (my $row = 0; $row < $y; ++$row) {
		foreach (my $col = 0; $col < $x; ++$col) {
			my $offset = $x * $z + $z
				+ $row * ($z + $x) * 2
				+ $col;
			$state[$offset] = $self->{__colors}->[2];
		}
	}

	# Fourth side (red).
	foreach (my $row = 0; $row < $y; ++$row) {
		foreach (my $col = 0; $col < $z; ++$col) {
			my $offset = $x * $z + $z + $x
				+ $row * ($z + $x) * 2
				+ $col;
			$state[$offset] = $self->{__colors}->[3];
		}
	}

	# Fifth side (yellow).
	foreach (my $row = 0; $row < $y; ++$row) {
		foreach (my $col = 0; $col < $x; ++$col) {
			my $offset = $x * $z + $z + $x + $z
				+ $row * ($z + $x) * 2
				+ $col;
			$state[$offset] = $self->{__colors}->[4];
		}
	}

	# Sixth side (blue).
	my $offset = $x * $z + ($z + $x) * 2 * $y;
	@state[$offset .. $offset + $x * $z - 1] =
		map { $self->{__colors}->[5] } (1 .. $x * $z);

	return $self;
}

sub xwidth { shift->{__xwidth} }

sub ywidth { shift->{__ywidth} }

sub zwidth { shift->{__zwidth} }

sub colors { shift->{__colors} }

sub state { @{shift->{__state}} }

sub move {
	my ($self, $move) = @_;

	if ($move !~ /^(0|(?:[1-9][0-9]*))([xyzXYZ])([123])$/) {
		require Carp;
		Carp::croak(__x("invalid move '{move}'", move => $move));
	}

	my ($coord, $layer, $turns) = ($1, $2, $3);
	$layer = lc $layer;
	if ('x' eq $layer) {
		if ($coord > $self->{__xwidth}) {
			require Carp;
			Carp::croak(__x("coordinate '{coord}' out of range (0 to {to})",
				coord => $coord, to => $self->{__xwidth}));
		}
	} elsif ('y' eq $layer) {
		if ($coord > $self->{__ywidth}) {
			require Carp;
			Carp::croak(__x("coordinate '{coord}' out of range (0 to {to})",
				coord => $coord, to => $self->{__ywidth}));
		}
	} else {
		if ($coord > $self->{__zwidth}) {
			require Carp;
			Carp::croak(__x("coordinate '{coord}' out of range (0 to {to})",
				coord => $coord, to => $self->{__zwidth}));
		}
	}

	return $self->fastMove($coord, (ord $layer) - (ord 'x'), $turns);
}

sub fastMove {
	my ($self, $coord, $layer, $turns) = @_;

	my $shifts = $self->{__shifts}->[$layer]->[$coord];
	my ($from, $to) = @{$shifts}[0, $turns];

	my $state = $self->{__state};
	@{$state}[@$to] = @{$state}[@$from];

	return $self;
}

1;
