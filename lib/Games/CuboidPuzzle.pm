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
	colors => [qw(B O Y R W G)],
);

sub new {
	my ($class, %args) = @_;

	my $self = {};
	bless $self, $class;

	foreach my $key (keys %defaults) {
		$self->{'__' . $key} = $args{$key} // $defaults{$key};
	}
	$self->{__state} = $args{state} if $args{state};

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
	$self->__setupYMoves;
	$self->__setupZMoves;
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

sub __setupYMoves {
	my ($self) = @_;

	my $layer_index = 1;

	my $xw = $self->{__xwidth};
	my $yw = $self->{__ywidth};
	my $zw = $self->{__zwidth};

	my ($l0, $l1, $l2, $l3, $l4, $l5) =
		map { $self->layerIndices($_) } (0 .. 5);
	my $single_turns = $yw == $zw;
	foreach my $y (0 .. $yw - 1) {
		my @cycles;
		foreach my $z (0 .. $zw - 1) {
			# Each cycle consists of 4 elements.  If single turns are not
			# possible, elements #1 and #3 are invalid but unused.
			my @cycle = ($l3->[$yw - $y - 1]->[$z]);
			push @cycle, $l2->[$yw - $y - 1]->[$z];
			push @cycle, $l1->[$yw - $y - 1]->[$z];
			push @cycle, $l4->[$yw - $y - 1]->[$z];
			push @cycles, \@cycle;
		}
		if ($y == 0) {
			push @cycles, $self->__rotateLayer($l5, 0);
		} elsif ($y == $zw - 1) {
			push @cycles, $self->__rotateLayer($l0, 0);
		}

		my @from;
		foreach my $cycle (@cycles) {
			push @from, @$cycle;
		}
		$self->{__shifts}->[$layer_index]->[$y + 1]->[0] = \@from;
		foreach my $turns (1 .. 3) {
			next if $turns != 2 && !$single_turns;

			my @to;
			foreach my $cycle (@cycles) {
				foreach my $i (0 .. 3) {
					push @to, $cycle->[($i + $turns) & 0x3];
				}
			}

			$self->{__shifts}->[$layer_index]->[$y + 1]->[$turns] = \@to;
		}
	}

	return $self;
}

sub __setupZMoves {
	my ($self) = @_;

	my $layer_index = 2;

	my $xw = $self->{__xwidth};
	my $yw = $self->{__ywidth};
	my $zw = $self->{__zwidth};

	my ($l0, $l1, $l2, $l3, $l4, $l5) =
		map { $self->layerIndices($_) } (0 .. 5);
	my $single_turns = $xw == $yw;
	foreach my $z (0 .. $zw - 1) {
		my @cycles;
		foreach my $x (0 .. $xw - 1) {
			# Each cycle consists of 4 elements.  If single turns are not
			# possible, elements #1 and #3 are invalid but unused.
			my @cycle = ($l0->[$zw - $z - 1]->[$x]);
			push @cycle, $l3->[$x]->[$z];
			push @cycle, $l5->[$z]->[$xw - $x - 1];
			push @cycle, $l1->[$yw - $x - 1]->[$zw - $z - 1];
			push @cycles, \@cycle;
		}
		if ($z == 0) {
			push @cycles, $self->__rotateLayer($l2, 0);
		} elsif ($z == $zw - 1) {
			push @cycles, $self->__rotateLayer($l4, 1);
		}

		my @from;
		foreach my $cycle (@cycles) {
			push @from, @$cycle;
		}
		$self->{__shifts}->[$layer_index]->[$z + 1]->[0] = \@from;
		foreach my $turns (1 .. 3) {
			next if $turns != 2 && !$single_turns;

			my @to;
			foreach my $cycle (@cycles) {
				foreach my $i (0 .. 3) {
					push @to, $cycle->[($i + $turns) & 0x3];
				}
			}

			$self->{__shifts}->[$layer_index]->[$z + 1]->[$turns] = \@to;
		}
	}

	return $self;
}

# This method is destructive!
sub __rotateLayer {
	my ($self, $layer, $ccw) = @_;

	if ($ccw) {
		foreach my $row (@$layer) {
			@$row = reverse @$row;
		}
	}

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

sub layerIndices {
	my ($self, $i) = @_;

	my $j = 0;
	my %colors = map { $_ => $j++ } @{$self->{__colors}};

	if (exists $colors{$i}) {
		$i = $colors{$i};
	} elsif ($i !~ /^[0-5]$/) {
		require Carp;
		Carp::croak(__x("invalid layer id '{id}'", id => $i));
	}

	my $xw = $self->xwidth;
	my $yw = $self->ywidth;
	my $zw = $self->zwidth;

	my @rows;
	# The layers are:
	#   0
	# 1 2 3 4
	#   5
	my @subs = (
		# Layer 0.
		sub {
			$i = 0;
			foreach my $rowno (0 .. $zw - 1) {
				my @cols;
				foreach my $colno (0 .. $xw - 1) {
					push @cols, $i++;
				}
				push @rows, \@cols;
			}
		},
		# Layer 1.
		sub {
			foreach my $rowno (0 .. $yw - 1) {
				my @cols;
				foreach my $colno (0 .. $zw - 1) {
					push @cols, $xw * $zw
						+ $rowno * 2 * ($zw + $xw)
						+ $colno;
				}
				push @rows, \@cols;
			}
		},
		# Layer 2.
		sub {
			foreach my $rowno (0 .. $yw - 1) {
				my @cols;
				foreach my $colno (0 .. $xw - 1) {
					push @cols, $xw * $zw
						+ $rowno * 2 * ($zw + $xw)
						+ $zw + $colno;
				}
				push @rows, \@cols;
			}
		},
		# Layer 3.
		sub {
			foreach my $rowno (0 .. $yw - 1) {
				my @cols;
				foreach my $colno (0 .. $zw - 1) {
					push @cols, $xw * $zw
						+ $rowno * 2 * ($zw + $xw)
						+ $zw + $xw + $colno;
				}
				push @rows, \@cols;
			}
		},
		# Layer 4.
		sub {
			foreach my $rowno (0 .. $yw - 1) {
				my @cols;
				foreach my $colno (0 .. $xw - 1) {
					push @cols, $xw * $zw
						+ $rowno * 2 * ($zw + $xw)
						+ 2 * $zw + $xw + $colno;
				}
				push @rows, \@cols;
			}
		},
		# Layer 5.
		sub {
			$i = $xw * $zw + $yw * 2 * ($zw + $xw);
			foreach my $rowno (0 .. $zw - 1) {
				my @cols;
				foreach my $colno (0 .. $xw - 1) {
					push @cols, $i++;
				}
				push @rows, \@cols;
			}
		},
	);

	if ($i > $#subs) {
		require Carp;
		Carp::croak(__"layer index {i} is out of range", i => $i);
	}

	$subs[$i]->();

	return \@rows;
}

1;
