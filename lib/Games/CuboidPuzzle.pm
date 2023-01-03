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
use POSIX qw(ceil);

use Games::CuboidPuzzle::Renderer::Simple;
use Games::CuboidPuzzle::MoveTranslator::Conventional;

my %defaults = (
	xwidth => 3,
	ywidth => 3,
	zwidth => 3,
	colors => [qw(B O Y R W G)],
	renderer => Games::CuboidPuzzle::Renderer::Simple->new,
	translator => Games::CuboidPuzzle::MoveTranslator::Conventional->new,
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
	$self->__setupRotations;
}

sub __setupXMoves {
	my ($self) = @_;

	my $layer_index = 0;

	my $xw = $self->{__xwidth};
	my $yw = $self->{__ywidth};
	my $zw = $self->{__zwidth};

	my ($l0, $l1, $l2, $l3, $l4, $l5) =
		map { $self->layerIndices($_) } (0 .. 5);
	my $single_turns = $yw == $zw;
	foreach my $x (0 .. $xw - 1) {
		my @cycles;
		if ($single_turns) {
			foreach my $z (0 .. $zw - 1) {
				push @cycles, [
					$l0->[$z]->[$x],
					$l2->[$z]->[$x],
					$l5->[$z]->[$x],
					$l4->[$zw - $z - 1]->[$xw - $x - 1]
				];
			}
			if ($x == 0) {
				push @cycles, $self->__rotateLayer($l1, 0);
			} elsif ($x == $xw - 1) {
				push @cycles, $self->__rotateLayer($l3, 1);
			}
		} else {
			foreach my $z (0 .. $zw - 1) {
				push @cycles, [
					$l0->[$z]->[$x],
					$l5->[$z]->[$x],
				];
			}
			foreach my $y (0 .. $yw - 1) {
				push @cycles, [
					$l2->[$y]->[$x],
					$l4->[$yw - $y - 1]->[$xw - $x - 1],
				];
			}
			if ($x == 0) {
				push @cycles, $self->__transposeLayer($l1);
			} elsif ($x == $xw - 1) {
				push @cycles, $self->__transposeLayer($l3);
			}
		}

		$self->__fillShifts($layer_index, $x, @cycles);
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
	my $single_turns = $xw == $zw;
	foreach my $y (0 .. $yw - 1) {
		my @cycles;
		if ($single_turns) {
			foreach my $z (0 .. $zw - 1) {
				push @cycles, [
					$l3->[$yw - $y - 1]->[$z],
					$l2->[$yw - $y - 1]->[$z],
					$l1->[$yw - $y - 1]->[$z],
					$l4->[$yw - $y - 1]->[$z]
				];
			}
			if ($y == 0) {
				push @cycles, $self->__rotateLayer($l5, 1);
			} elsif ($y == $yw - 1) {
				push @cycles, $self->__rotateLayer($l0, 0);
			}
		} else {
			foreach my $z (0 .. $zw - 1) {
				push @cycles, [
					$l3->[$yw - $y - 1]->[$z],
					$l1->[$yw - $y - 1]->[$z],
				];
			}
			foreach my $x (0 .. $xw - 1) {
				push @cycles, [
					$l2->[$yw - $y - 1]->[$x],
					$l4->[$yw - $y - 1]->[$x],
				];
			}
			if ($y == 0) {
				push @cycles, $self->__transposeLayer($l5);
			} elsif ($y == $yw - 1) {
				push @cycles, $self->__transposeLayer($l0);
			}
		}

		$self->__fillShifts($layer_index, $y, @cycles);
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
		if ($single_turns) {
			foreach my $x (0 .. $xw - 1) {
				push @cycles, [
					$l0->[$zw - $z - 1]->[$x],
					$l3->[$x]->[$z],
					$l5->[$z]->[$xw - $x - 1],
					$l1->[$yw - $x - 1]->[$zw - $z - 1]
				];
			}
			if ($z == 0) {
				push @cycles, $self->__rotateLayer($l2, 0);
			} elsif ($z == $zw - 1) {
				push @cycles, $self->__rotateLayer($l4, 1);
			}
		} else {
			foreach my $x (0 .. $xw - 1) {
				push @cycles, [
					$l0->[$zw - $z - 1]->[$x],
					$l5->[$z]->[$xw - $x - 1]
				];
			}
			foreach my $y (0 .. $yw - 1) {
				push @cycles, [
					$l3->[$y]->[$z],
					$l1->[$yw - $y - 1]->[$zw - $z - 1],
				];
			}
			if ($z == 0) {
				push @cycles, $self->__transposeLayer($l2);
			} elsif ($z == $zw - 1) {
				push @cycles, $self->__transposeLayer($l4);
			}
		}

		$self->__fillShifts($layer_index, $z, @cycles);
	}

	return $self;
}

sub __fillShifts {
	my ($self, $layer_index, $coord, @cycles) = @_;

	my @from;
	foreach my $cycle (@cycles) {
		push @from, @$cycle;
	}

	$self->{__shifts}->[$layer_index]->[$coord + 1]->[0] = \@from;
	my @turns = (4 == @{$cycles[0]}) ? (1 .. 3) : (2);
	foreach my $turns (@turns) {
		my @to;
		foreach my $cycle (@cycles) {
			push @$cycle, shift @$cycle;
			push @to, @$cycle;
		}
		$self->{__shifts}->[$layer_index]->[$coord + 1]->[$turns] = \@to;
	}

	return $self;
}

sub __rotateLayer {
	my ($self, $layer, $ccw) = @_;

	if ($ccw) {
		foreach my $row (@$layer) {
			@$row = reverse @$row;
		}
	}

	my $centre = ceil $#$layer / 2;
	my $max = $#$layer;

	my @cycles;
	foreach my $depth (0 .. $centre) {
		my $end = $max - $depth;
		last if $end == $depth;
		foreach my $x ($depth .. $max - $depth - 1) {
			push @cycles, [
				$layer->[$depth]->[$x],
				$layer->[$x]->[$end],
				$layer->[$end]->[$end - $x + $depth],
				$layer->[$end - $x + $depth]->[$depth],
			];
		}
	}

	return @cycles;
}

sub __transposeLayer {
	my ($self, $layer) = @_;

	my @cycles;
	my $rows = @$layer;
	my $cols = @{$layer->[0]};
	my $last = ($rows * $cols) >> 1;
	CYCLE: foreach my $row (0 .. $rows - 1) {
		foreach my $col (0 .. $cols - 1) {
			last CYCLE if $row * $cols + $col >= $last;
			push @cycles, [
				$layer->[$row]->[$col],
				$layer->[$rows - $row - 1]->[$cols - $col - 1]
			];
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

sub state {
	wantarray ? @{shift->{__state}} : join ':', @{shift->{__state} };
}

sub move {
	my ($self, $move) = @_;

	my ($coord, $layer, $width, $turns) = $self->parseMove($move);
	if (!defined $coord) {
		require Carp;
		Carp::croak(__x("invalid move '{move}'", move => $move));
	}

	die "wide moves not yet supported" if $width != 1;

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

	if (!$self->fastMove($coord, (ord $layer) - (ord 'x'), $turns)) {
		require Carp;
		Carp::croak(__x("this cube does not support the move '{move}'",
			move => $move));
	}
}

sub __setupRotations {
	my ($self) = @_;

	foreach my $layer_shifts (@{$self->{__shifts}}) {
		my @from;
		foreach my $coords (1 .. $#$layer_shifts) {
			my $coord_shifts = $layer_shifts->[$coords];
			push @from, @{$coord_shifts->[0]};
		}
		$layer_shifts->[0]->[0] = \@from;

		foreach my $turns (1 .. 3) {
			next if !defined $layer_shifts->[1]->[$turns];
			my @to;
			foreach my $coords (1 .. $#$layer_shifts) {
				my $coord_shifts = $layer_shifts->[$coords];
				push @to, @{$coord_shifts->[$turns]};
			}

			my @to_sorted;
			foreach my $i (0 .. $#from) {
				my $from = $from[$i];
				my $to = $to[$i];
				$to_sorted[$from[$i]] = $to[$i];
			}
			foreach my $i (0 .. $#to_sorted) {
				# Rotated centre?
				$to_sorted[$i] //= $i;
			}
			$layer_shifts->[0]->[$turns] = \@to;
		}
	}

	return $self;
}

sub fastMove {
	my ($self, $coord, $layer, $turns) = @_;

	my $shifts = $self->{__shifts}->[$layer]->[$coord];
	my ($from, $to) = @{$shifts}[0, $turns];

	return if !defined $to;

	my $state = $self->{__state};
	@{$state}[@$to] = @{$state}[@$from];

	return $self;
}

sub layerIndices {
	my ($self, $i) = @_;

	# FIXME! The tables should be pre-calculated for performance reasons!
	# FIXME! There should be a "flat" version that returns a flat list instead
	# an array of an array.
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

# If MOVE is applied to the cube, what would be the equivalent move of
# ROTATION is applied first?
sub rotateMove {
	my ($self, $move, $rotation) = @_;

	my ($move_coord, $move_layer, $move_width, $move_turns) = $self->parseMove($move);
	if (!defined $move_coord) {
		require Carp;
		Carp::croak(__x("invalid move '{move}'", move => $move));
	}

	my ($rot_coord, $rot_layer, $rot_width, $rot_turns) = $self->parseMove($rotation);
	if (!defined $rot_coord) {
		require Carp;
		Carp::croak(__x("invalid rotation '{rotation}'", rotation => $rotation));
	}

	if ($rot_coord != 0) {
		require Carp;
		Carp::croak(__x("rotation '{rotation}' is not a rotation move",
			rotation => $rotation));
	}
	$rot_layer eq lc $rot_layer;

	return $move if $rot_layer eq $move_layer;

	my $layer = "xyz";
	$layer =~ s/$move_layer//;
	$layer =~ s/$rot_layer//;
	my $width = $self->{"__${layer}width"};

	if ($rot_turns == 2) {
		my $turns = 4 - $move_turns;
		my $coord = $width + 1 - $move_coord;
		return "$coord$move_layer$turns";
	}

	# The key is the roation axis, the inner key the layer that moves.
	# Do the coordinate or the number of turns change if we rotate by
	# 90 degrees in clock-wise direction?
	my %transform = (
		x => {
			y => {
				coord => 1,
			},
			z => {
				turns => 1,
			}
		},
		y => {
			x => {
				coord => 1,
				turns => 1,
			},
			z => {
			}
		},
		z => {
			x => {
				coord => 1,
			},
			y => {
				turns => 3,
			},
		}
	);
	my ($coord, $turns);
	my $transformer = $transform{$rot_layer}->{$move_layer};
	if (1 == $rot_turns) {
		$coord = $transformer->{coord} ? $width + 1 - $move_coord : $move_coord;
		$turns = $transformer->{turns} ? 4 - $move_turns : $move_turns;
	} else {
		$coord = !$transformer->{coord} ? $width + 1 - $move_coord : $move_coord;
		$turns = !$transformer->{turns} ? 4 - $move_turns : $move_turns;
	}

	$move_width = '' if 1 == $move_width;

	return "$coord$layer$move_width$turns";
}

sub render {
	my ($self) = @_;

	return $self->{__renderer}->render($self);
}

sub parseMove {
	my (undef, $move) = @_;

	return if $move !~ /^(0|(?:[1-9][0-9]*))([xyzXYZ])([1-9][0-9]*)?([123])$/;

	my ($coord, $layer, $width, $turns) = ($1, $2, $3, $4);
	$layer = lc $layer;

	$width //= 1;

	return $coord, $layer, $width, $turns;
}

sub conditionSolved {
	my ($self, $layer_id) = @_;

	my ($from, $to) = defined $layer_id ? ($layer_id, $layer_id) : (0 .. 5);
	foreach my $i ($from .. $to) {
	}

	return $self;
}

1;
