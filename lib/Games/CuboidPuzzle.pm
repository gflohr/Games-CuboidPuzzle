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
use List::MoreUtils qw(uniq);

use Games::CuboidPuzzle::Renderer::Simple;
use Games::CuboidPuzzle::Notation::Conventional;

my %defaults = (
	xwidth => 3,
	ywidth => 3,
	zwidth => 3,
	# FIXME! Optionally split by space if scalar!
	colours => [qw(B O Y R W G)],
	# FIXME! Use identifiers, not packages!
	renderer => Games::CuboidPuzzle::Renderer::Simple->new,
	notation => 'conventional',
);

sub new {
	my ($class, %args) = @_;

	my $self = {};
	bless $self, $class;

	$args{colours} //= $args{colors};
	foreach my $key (keys %defaults) {
		$self->{'__' . $key} = $args{$key} // $defaults{$key};
	}

	# FIXME! Optionally split by space if scalar!
	$self->{__state} = $args{state} if $args{state};

	# Upgrade notation.
	my $notation = 'Games::CuboidPuzzle::Notation::'
		. ucfirst lc $self->{__notation};
	my $notation_module = $notation;
	$notation_module =~ s{::}{/}g;
	$notation_module .= '.pm';
	eval { require $notation_module };
	if ($@) {
		warn $@;
		require Carp;
		Carp::croak(__x("unsupported or invalid notation '{notation}'",
			notation => $self->{__notation}));
	}
	$self->{__notation} = $notation->new;

	if (@{$self->{__colours}} != 6) {
		require Carp;
		Carp::croak(__"exactly 6 colours required")
	}

	my %colours = map { $_ => 1 } @{$self->{__colours}};
	if (keys %colours != 6) {
		require Carp;
		Carp::croak(__"colours must be unique")
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

	$self->{__adjacentFaces} = [
		[1, 2, 3, 4],
		[0, 2, 4, 5],
		[0, 1, 3, 5],
		[0, 2, 4, 5],
		[0, 1, 3, 5],
		[1, 2, 3, 4],
	];
	$self->__setupLayerIndices;
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
	@state[0 .. $x * $z - 1] = map { $self->{__colours}->[0] } (1 .. $x * $z);

	# Second side (orange).
	foreach (my $row = 0; $row < $y; ++$row) {
		foreach (my $col = 0; $col < $z; ++$col) {
			my $offset = $x * $z
				+ $row * ($z + $x) * 2
				+ $col;
			$state[$offset] = $self->{__colours}->[1];
		}
	}

	# Third side (white).
	foreach (my $row = 0; $row < $y; ++$row) {
		foreach (my $col = 0; $col < $x; ++$col) {
			my $offset = $x * $z + $z
				+ $row * ($z + $x) * 2
				+ $col;
			$state[$offset] = $self->{__colours}->[2];
		}
	}

	# Fourth side (red).
	foreach (my $row = 0; $row < $y; ++$row) {
		foreach (my $col = 0; $col < $z; ++$col) {
			my $offset = $x * $z + $z + $x
				+ $row * ($z + $x) * 2
				+ $col;
			$state[$offset] = $self->{__colours}->[3];
		}
	}

	# Fifth side (yellow).
	foreach (my $row = 0; $row < $y; ++$row) {
		foreach (my $col = 0; $col < $x; ++$col) {
			my $offset = $x * $z + $z + $x + $z
				+ $row * ($z + $x) * 2
				+ $col;
			$state[$offset] = $self->{__colours}->[4];
		}
	}

	# Sixth side (blue).
	my $offset = $x * $z + ($z + $x) * 2 * $y;
	@state[$offset .. $offset + $x * $z - 1] =
		map { $self->{__colours}->[5] } (1 .. $x * $z);

	return $self;
}

sub xwidth { shift->{__xwidth} }

sub ywidth { shift->{__ywidth} }

sub zwidth { shift->{__zwidth} }

sub colours { shift->{__colours} }

sub colors { shift->{__colours} }

sub state {
	wantarray ? @{shift->{__state}} : join ':', @{shift->{__state} };
}

sub __checkMove {
	my ($self, $move) = @_;

	my $internal_move = $self->parseMove($move);
	die __x("invalid move '{move}'\n", move => $move)
		if !defined $internal_move;

	my ($coord, $layer, $width, $turns)
		= $self->parseInternalMove($internal_move);
	die __x("invalid move '{move}'\n", move => $move)
		if !defined $coord;

	die "wide moves not yet supported\n" if $width != 1;

	if (0 == $layer) {
		if ($coord > $self->{__xwidth}) {
			die __x("coordinate '{coord}' out of range (0 to {to})\n",
				coord => $coord, to => $self->{__xwidth});
		}
	} elsif (1 == $layer) {
		if ($coord > $self->{__ywidth}) {
			die __x("coordinate '{coord}' out of range (0 to {to})\n",
				coord => $coord, to => $self->{__ywidth});
		}
	} else {
		if ($coord > $self->{__zwidth}) {
			die __x("coordinate '{coord}' out of range (0 to {to})\n",
				coord => $coord, to => $self->{__zwidth});
		}
	}

	return $coord, $layer, $width, $turns;
}

sub move {
	my ($self, @moves) = @_;

	foreach my $move (@moves) {
		my ($coord, $layer, $width, $turns) = eval {
			$self->__checkMove($move);
		};
		if ($@) {
			my $error = $@;
			chop $@;
			require Carp;
			Carp::croak($@);
		}

		if (!$self->fastMove($coord, $layer, 1, $turns)) {
			require Carp;
			Carp::croak(__x("this cube does not support the move '{move}'",
				move => $move));
		}
	}

	return $self;
}

sub unmove {
	my ($self, @moves) = @_;

	foreach my $move (reverse @moves) {
		my ($coord, $layer, $width, $turns) = eval {
			$self->__checkMove($move);
		};
		if ($@) {
			my $error = $@;
			chop $@;
			require Carp;
			Carp::croak($@);
		}

		if (!$self->fastMove($coord, $layer, 1, 4 - $turns)) {
			require Carp;
			Carp::croak(__x("this cube does not support the move '{move}'",
				move => $move));
		}
	}

	return $self;
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
	my ($self, $coord, $layer, $width, $turns) = @_;

	die "wide moves not yet supported" if $width != 1;

	my $shifts = $self->{__shifts}->[$layer]->[$coord];
	my ($from, $to) = @{$shifts}[0, $turns];

	return if !defined $to;

	my $state = $self->{__state};
	@{$state}[@$to] = @{$state}[@$from];

	return $self;
}

sub ultraFastMove {
	my $shifts = $_[0]->{__shifts}->[$_[2]]->[$_[1]];
	my ($from, $to) = @{$shifts}[0, $_[4]];

	my $state = $_[0]->{__state};
	@{$state}[@$to] = @{$state}[@$from];
}

sub layerIndices {
	my ($self, $i) = @_;

	my $j = 0;
	my %colours = map { $_ => $j++ } @{$self->{__colours}};

	if (exists $colours{$i}) {
		$i = $colours{$i};
	} elsif ($i !~ /^[0-5]$/) {
		require Carp;
		Carp::croak(__x("invalid layer id '{id}'", id => $i));
	}

	my @matrix = @{$self->{__layerIndices}->[$i]};
	foreach my $row (@matrix) {
		$row = [@$row];
	}

	return \@matrix;
}

sub layerIndicesFlattened {
	my ($self, $i) = @_;

	my $j = 0;
	my %colours = map { $_ => $j++ } @{$self->{__colours}};

	if (exists $colours{$i}) {
		$i = $colours{$i};
	} elsif ($i !~ /^[0-5]$/) {
		require Carp;
		Carp::croak(__x("invalid layer id '{id}'", id => $i));
	}

	return @{$self->{__layerIndicesFlattened}->[$i]};
}

sub crossIndicesFlattened {
	my ($self, $i) = @_;

	my $j = 0;
	my %colours = map { $_ => $j++ } @{$self->{__colours}};

	if (exists $colours{$i}) {
		$i = $colours{$i};
	} elsif ($i !~ /^[0-5]$/) {
		require Carp;
		Carp::croak(__x("invalid layer id '{id}'", id => $i));
	}

	return @{$self->{__crossIndicesFlattened}->[$i]};
}

sub __setupLayerIndices {
	my ($self) = @_;

	my $xw = $self->xwidth;
	my $yw = $self->ywidth;
	my $zw = $self->zwidth;

	my @layerIndices;
	my @layerIndicesFlattened;
	my @crossIndicesFlattened;
	my @edgeIndicesFlattened;
	foreach my $i (0 .. 5) {
		my @rows;
		my @edges;
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

				if ($xw > 2 && $yw > 2) {
					my $i = $xw * $zw + 2 * $zw + $xw + 1;
					$edges[0] = [$i .. $i + $xw - 3];
					$i += 2 * ($xw + $zw);
					push @{$edges[0]}, ($i .. $i + $xw - 3);

					$i = $xw * $zw + $zw + 1;
					$edges[2] = [$i .. $i + $xw - 3];
					$i += 2 * ($xw + $zw);
					push @{$edges[2]}, ($i .. $i + $xw - 3);
				}

				if ($zw > 2 && $yw > 2) {
					my $i = $xw * $zw + $zw + $xw + 1;
					$edges[1] = [$i .. $i + $zw - 3];
					$i += 2 * ($xw + $zw);
					push @{$edges[1]}, ($i .. $i + $zw - 3);

					$i = $xw * $zw + 1;
					push @{$edges[3]}, ($i .. $i + $zw - 3);
					$i += 2 * ($xw + $zw);
					push @{$edges[3]}, ($i .. $i + $zw - 3);
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

				if ($zw > 2 && $xw > 2) {
					$edges[0] = [];
					foreach my $row (1 .. $zw - 2) {
						my $i = $row * $xw;
						push @{$edges[0]}, ($i, $i + 1);

						$i = $xw * $zw + $yw * 2 * ($xw + $zw) + $row * $xw;
						push @{$edges[2]}, ($i, $i + 1);
					}
				}
				if ($yw > 2 && $xw > 2) {
					foreach my $row (1 .. $yw - 2) {
						my $i = $xw * $zw + $row * 2 * ($xw + $zw) + $zw;
						push @{$edges[1]}, ($i, $i + 1);

						$i = $xw * $zw + ($row + 1) * 2 * ($xw + $zw) - 2;
						push @{$edges[3]}, ($i, $i + 1);
					}
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

				if ($xw > 2 && $zw > 2) {
					my $i = $xw * $zw - 2 * $xw + 1;
					push @{$edges[0]}, ($i .. $i + $xw - 3);
					push @{$edges[0]}, ($i + $xw .. $i + 2 * $xw - 3);

					$i = $xw * $zw + $yw * 2 * ($xw + $zw) + 1;
					push @{$edges[2]}, ($i .. $i + $xw - 3);
					push @{$edges[2]}, ($i + $xw .. $i + 2 * $xw - 3);
				}

				if ($yw > 2 && $zw > 2) {
					foreach my $row (1 .. $yw - 2) {
						my $i = $xw * $zw + $row * 2 * ($xw + $zw) + $zw + $xw;
						push @{$edges[1]}, ($i, $i + 1);

						$i = $xw * $zw + $row * 2 * ($xw + $zw) + $zw - 2;
						push @{$edges[3]}, ($i, $i + 1);
					}
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

				if ($zw > 2 && $xw > 2) {
					foreach my $col (1 .. $zw - 2) {
						my $i = $col * $xw + $xw - 2;
						push @{$edges[0]}, ($i, $i + 1);

						$i = $xw * $zw + $yw * 2 * ($xw + $zw) + $col * $xw + $xw - 2;
						push @{$edges[2]}, ($i, $i + 1);
					}
				}

				if ($yw > 2 && $xw > 2) {
					foreach my $row (1 .. $yw - 2) {
						my $i = $xw * $zw + $row * 2 * ($xw + $zw) + 2 * $zw + $xw;
						push @{$edges[1]}, ($i, $i + 1);

						$i = $xw * $zw + $row * 2 * ($xw + $zw) + $zw + $xw - 2;
						push @{$edges[3]}, ($i, $i + 1);
					}
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

				if ($xw > 2 && $zw > 2) {
					my $i = 1;
					push @{$edges[0]}, ($i .. $xw - 2);
					push @{$edges[0]}, ($i + $xw .. 2 * $xw - 2);

					$i = $xw * $zw + $yw * 2 * ($xw + $zw) + ($zw - 2) * $xw + 1;
					push @{$edges[2]}, ($i .. $i + $xw - 3);
					$i += $xw;
					push @{$edges[2]}, ($i .. $i + $xw - 3);
				}

				if ($yw > 2 && $zw > 2) {
					foreach my $row (1 .. $yw - 2) {
						my $i = $xw * $zw + $row * 2 * ($xw + $zw);
						push @{$edges[1]}, ($i, $i + 1);

						$i = $xw * $zw + $row * 2 * ($xw + $zw) + $xw + $zw;
						push @{$edges[3]}, ($i, $i + 1);
					}
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

				if ($xw > 2 && $yw > 2) {
					my $i = $xw * $zw + $yw * 2 * ($xw + $zw) + 1;
					push @{$edges[0]}, ($i .. $i + $xw - 3);
					push @{$edges[0]}, ($i + $xw.. $i + 2 * $xw - 3);

					$i = $xw * $zw + ($yw - 1) * 2 * ($xw + $zw) - $xw + 1;
					push @{$edges[2]}, ($i .. $i + $xw - 3);
					push @{$edges[2]}, ($i + 2 * ($xw + $zw) .. $i + $xw + 2 * ($xw + $zw) - 3);
				}

				if ($zw > 2 && $yw > 2) {
					my $i = $xw * $zw + ($yw - 2) * 2 * ($xw + $zw) + $xw + $zw + 1;
					push @{$edges[1]}, ($i .. $i + $zw - 3);
					push @{$edges[1]}, ($i + 2 * ($xw + $zw) .. $i + 2 * ($xw + $zw) + $zw - 3);

					$i = $xw * $zw + ($yw - 2) * 2 * ($xw + $zw) + 1;
					push @{$edges[3]}, ($i .. $i + $zw - 3);
					push @{$edges[3]}, ($i + 2 * ($xw + $zw) .. $i + 2 * ($xw + $zw) + $zw - 3);
				}
			},
		);

		$subs[$i]->();

		push @layerIndices, \@rows;
		my @flattened = map { @$_ } @rows;
		push @layerIndicesFlattened, \@flattened;
		push @edgeIndicesFlattened, \@edges;

		my @cross;
		for (my $i = 1; $i < $#{$rows[0]}; ++$i) {
			push @cross, $rows[0]->[$i];
		}
		if (@rows > 2) {
			for (my $i = 1; $i < $#rows; ++$i) {
				push @cross, @{$rows[$i]};
			}
		}
		if (@rows > 1) {
			for (my $i = 1; $i < $#{$rows[-1]}; ++$i) {
				push @cross, $rows[-1]->[$i];
			}
		}
		push @crossIndicesFlattened, \@cross;
	}

	$self->{__layerIndices} = \@layerIndices;
	$self->{__layerIndicesFlattened} = \@layerIndicesFlattened;
	$self->{__crossIndicesFlattened} = \@crossIndicesFlattened;
	$self->{__edgeIndicesFlattened} = \@edgeIndicesFlattened;

	return $self;
}

# If MOVE is applied to the cube, what would be the equivalent move of
# ROTATION is applied first?
sub rotateMove {
	my ($self, $move, $rotation) = @_;

	my $internal_move = $self->parseMove($move);
	if (!defined $internal_move) {
		require Carp;
		Carp::croak(__x("invalid move '{move}'", move => $move));
	}

	my $internal_rotation = $self->parseMove($rotation);
	if (!defined $internal_rotation) {
		require Carp;
		Carp::croak(__x("invalid rotation '{rotation}'\n", rotation => $rotation));
	}

	my $rotated_internal_move = eval {
		$self->__rotateInternalMove(
			$internal_move, $move,
			$internal_rotation, $rotation
		);
	};
	if ($@) {
		require Carp;
		my $x = $@;
		chomp $x;
		Carp::croak($x);
	}

	my @rotated_moves = eval {
		$self->{__notation}->translate($rotated_internal_move, $self);
	};
	if ($@) {
		die(__x("notation cannot translate rotated_move '{rotated_move}'",
			rotated_move => $rotated_internal_move));
	}

	return @rotated_moves;
}

sub __rotateInternalMove {
	my ($self, $internal_move, $move, $internal_rotation, $rotation) = @_;

	my ($move_coord, $move_layer, $move_width, $move_turns) = $self->parseInternalMove($internal_move);
	if (!defined $move_coord) {
		die __x("invalid move '{move}'\n", move => $move);
	}

	my ($rot_coord, $rot_layer, $rot_width, $rot_turns) = $self->parseInternalMove($internal_rotation);
	if (!defined $rot_coord) {
		die __x("invalid rotation '{rotation}'\n", rotation => $rotation);
	}

	if ($rot_coord != 0) {
		die __x("rotation '{rotation}' is not a rotation move\n",
			rotation => $rotation);
	}

	if ($rot_layer == $move_layer) {
		$move_width = '' if 1 == $move_width;
		$move_layer = chr($move_layer + ord 'x');
		return "$move_coord$move_layer$move_width$move_turns";
	}

	my $layer = "012";
	$layer =~ s/$move_layer//;
	$layer =~ s/$rot_layer//;
	my $layer_id = chr($layer + ord 'x');
	my $width = $self->{"__${layer_id}width"};

	if ($rot_turns == 2) {
		my $turns = 4 - $move_turns;
		my $coord = $width + 1 - $move_coord;
		my $move_layer_id = chr($move_layer + ord 'x');
		$move_width = '' if 1 == $move_width;

		return "$coord$move_layer_id$move_width$turns";
	}

	# The key is the roation axis, the inner key the layer that moves.
	# Do the coordinate or the number of turns change if we rotate by
	# 90 degrees in clock-wise direction?
	my @transform = (
		[
			undef,
			{
				coord => 1,
			},
			{
				turns => 1,
			}
		],
		[
			{
				coord => 1,
				turns => 1,
			},
		],
		[
			{
				coord => 1,
			},
			{
				turns => 3,
			},
		],
	);
	my ($coord, $turns);
	my $transformer = $transform[$rot_layer]->[$move_layer];
	if (1 == $rot_turns) {
		$coord = $transformer->{coord} ? $width + 1 - $move_coord : $move_coord;
		$turns = $transformer->{turns} ? 4 - $move_turns : $move_turns;
	} else {
		$coord = !$transformer->{coord} ? $width + 1 - $move_coord : $move_coord;
		$turns = !$transformer->{turns} ? 4 - $move_turns : $move_turns;
	}

	$move_width = '' if 1 == $move_width;

	die if $layer_id ne chr($layer + ord('x'));

	return "$coord$layer_id$move_width$turns";
}

sub rotateMovesToBottom {
	my ($self, $colour, @moves) = @_;

	my $layer = $self->findLayer($colour);
	if (!defined $layer && $layer !~ /^[0..5]$/) {
		require Carp;
		Carp::croak(__x("cube has no layer with colour '{colour}'",
		                colour => $colour));
	}

	# Which internal moves rotate a layer to the bottom.
	my @bottom_rotations = ('0x1', '0y3', undef, '0y1', '0x2', '0x3');
	my @internal_moves = map { $self->parseMove($_) } @moves;
	my @rotated_moves;
	if ($layer != 2) {
		my $internal_rotation = $bottom_rotations[$layer];
		my $max_bonus = -1;
		foreach my $second_rotation (undef, '0z1', '0z3', '0z2') {
			my @try;
			foreach my $i (0 .. $#internal_moves) {
				my $internal_move = $internal_moves[$i];
				my $rotated_internal_move =
					$self->__rotateInternalMove(
						$internal_move, '?',
						$internal_rotation, '?',
					);
				push @try, $rotated_internal_move;
			}
			if (defined $second_rotation) {
				foreach my $i (0 .. $#try) {
					my $internal_move = $try[$i];
					my $rotated_internal_move =
						$self->__rotateInternalMove(
							$internal_move, '?',
							$second_rotation, '?',
						);
					@try[$i] = $rotated_internal_move;
				}
			}

			my $bonus = 0;
			foreach my $move (@try) {
				if ($move =~ /x/) {
					$bonus += 2;
				} elsif ($move =~ /1y/) {
					++$bonus;
				}
			}
			if ($bonus > $max_bonus) {
				@rotated_moves = ($internal_rotation);
				push @rotated_moves, $second_rotation
					if defined $second_rotation;
				push @rotated_moves, @try;
				$max_bonus = $bonus;
			}
		}
	} else {
		@rotated_moves = @internal_moves;
	}

	my @parsed_rotated_moves = map {
		[$self->parseInternalMove($_)]
	} @rotated_moves;

	my @parsed_moves = map { [$self->parseInternalMove($_)] } @rotated_moves;
	foreach my $move (@parsed_moves) {
		$self->ultraFastMove(@$move);
	}

	my $new_layer = $self->findLayer($colour);
	my @final_rotations;
	if ($new_layer != 2) {
		# Slice moves implicitely rotate the cube.
		my $internal_rotation = $bottom_rotations[$layer];
		push @final_rotations, $internal_rotation;
	}

	# Revert.
	foreach my $move (reverse @parsed_moves) {
		$move->[3] = 4 - $move->[3];
		$self->ultraFastMove(@$move);
	}

	push @rotated_moves, @final_rotations;

	return map { $self->{__notation}->translate($_, $self) } @rotated_moves;
}

sub render {
	my ($self) = @_;

	return $self->{__renderer}->render($self);
}

sub parseMove {
	my ($self, $move) = @_;

	my $internal_move = eval { $self->{__notation}->parse($move, $self) };

	if ($@) {
		require Carp;
		Carp::croak(__x("invalid move '{move}'", move => $move));
	}

	return $internal_move;
}

sub parseInternalMove {
	my (undef, $move) = @_;

	return if $move !~ /^(0|(?:[1-9][0-9]*))([xyzXYZ])([1-9][0-9]*)?([123])$/;

	my ($coord, $layer, $width, $turns) = ($1, $2, $3, $4);
	$layer = ord(lc $layer) - ord('x');

	$width //= 1;

	return $coord, $layer, $width, $turns;
}

sub conditionSolved {
	my ($self) = @_;

	my $layerIndicesFlattened = $self->{__layerIndicesFlattened};
	foreach my $i (0 .. 5) {
		my @colours = uniq @{$self->{__state}}[@{$layerIndicesFlattened->[$i]}];
		return if $#colours;
	}

	return $self;
}

sub findLayer {
	my ($self, $colour) = @_;

	foreach my $layer (0 .. 5) {
		my $layer_indices = $self->layerIndices($layer);
		my @rows = @$layer_indices;
		if ($#rows & 0x1) {
			require Carp;
			Carp::croak("layer {layer} has an even number of rows",
				layer => $layer);
		}
		my @stickers = @{$rows[$#rows >> 1]};
		if ($#stickers & 0x1) {
			require Carp;
			Carp::croak("layer {layer} has an even number of columns",
				layer => $layer);
		}
		my $index = $stickers[$#stickers >> 1];
		return $layer if $self->{__state}->[$index] eq $colour;
	}

	return;
}

sub conditionCrossSolved {
	my ($self, $layer) = @_;

	my $crossIndicesFlattened = $self->{__crossIndicesFlattened}->[$layer];
	my @colours = uniq @{$self->{__state}}[@$crossIndicesFlattened];
	return if $#colours;

	# Check the edges. It is enough to check 3 sides because the 4th must be
	# solved if the other 3 are okay.
	my $edge_indices = $self->{__edgeIndicesFlattened}->[$layer];
	foreach my $face (0 .. 2) {
		@colours = uniq @{$self->{__state}}[@{$edge_indices->[$face]}];
		return if $#colours;
	}

	return $self;
}

sub conditionAnyCrossSolved {
	my ($self) = @_;

	my $crossIndicesFlattened = $self->{__crossIndicesFlattened};
	LAYER: foreach my $i (0 .. 5) {
		my @colours = uniq @{$self->{__state}}[@{$crossIndicesFlattened->[$i]}];
		next if $#colours;

		my $edge_indices = $self->{__edgeIndicesFlattened}->[$i];
		foreach my $face (0 .. 2) {
			@colours = uniq @{$self->{__state}}[@{$edge_indices->[$face]}];
			next LAYER if $#colours;
		}

		return $self;
	}

	return;
}

sub translateMove {
	my ($self, $internal_move) = @_;

	return $self->{__notation}->translate($internal_move, $self);
}

sub supportedMoves {
	my ($self) = @_;

	my @moves;
	my @layer_ids = qw(x y z);
	my $shifts = $self->{__shifts};
	foreach my $layer (0 .. $#$shifts) {
		my $layer_id = $layer_ids[$layer];
		my $coords = $shifts->[$layer];
		foreach my $coord (0 .. $#$coords) {
			foreach my $turns (1 .. 3) {
				next if !defined $coords->[$turns];
				push @moves, "$coord$layer_id$turns";
			}
		}
	}

	my @translated;
	foreach my $move (@moves) {
		push @translated, $self->translateMove($move);
	}

	return @translated;
}

1;
