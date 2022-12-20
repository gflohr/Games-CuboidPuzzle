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

	bless $self, $class;

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

	return $self;
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

	if ($move =~ /([RrMLlUuEDdFfSBb])([1-3'])?$/) {
		my $original_move = $move;
		$move = $1;
		my $count = $2 || 1;
		$count = 3 if $count eq "'";
		my $translator = "__translate$move";
		$move = $self->$translator($move);
		if (!$move) {
			require Carp;
			Carp::croak(__x("invalid move '{move}' for this cube",
				move => $original_move));
		}
		$move .= $count;
	}


	return $self;
}

sub __translateR {
	my ($self, $move) = @_;

	if ($self->xwidth == 3) {
		return '3x';
	} elsif ($self->xwidth == 2) {
		return '2x';
	} elsif ($self->xwidth == 1) {
		return '1x';
	}

	return;
}

sub __translateM {
	my ($self, $move) = @_;

	if ($self->xwidth == 3) {
		return '2x';
	} elsif ($self->xwidth == 1) {
		return '1x';
	}

	return;
}

sub __translateL {
	my ($self, $move) = @_;

	if ($self->xwidth <= 3) {
		return '1x';
	}

	return;
}

sub __translateF {
	my ($self, $move) = @_;

	if ($self->ywidth <= 3) {
		return '1y';
	}

	return;
}

sub __translateS {
	my ($self, $move) = @_;

	if ($self->ywidth == 3) {
		return '2y';
	} elsif ($self->ywidth == 1) {
		return '1y';
	}

	return;
}

sub __translateB {
	my ($self, $move) = @_;

	if ($self->ywidth == 3) {
		return '3y';
	} elsif ($self->ywidth == 2) {
		return '2y';
	} elsif ($self->ywidth == 1) {
		return '1y';
	}

	return;
}

sub __translateD {
	my ($self, $move) = @_;

	if ($self->zwidth <= 3) {
		return '1z';
	}

	return;
}

sub __translateE {
	my ($self, $move) = @_;

	if ($self->zwidth == 3) {
		return '2z';
	} elsif ($self->zwidth == 1) {
		return '1z';
	}

	return;
}

sub __translateU {
	my ($self, $move) = @_;

	if ($self->zwidth == 3) {
		return '3z';
	} elsif ($self->zwidth == 2) {
		return '2z';
	} elsif ($self->zwidth == 1) {
		return '1z';
	}

	return;
}

sub __translater {
	my ($self, $move) = @_;

	if ($self->xwidth == 3) {
		return '2x';
	}

	return;
}

sub __translatel {
	my ($self, $move) = @_;

	if ($self->xwidth == 3) {
		return '2x';
	}

	return;
}

sub __translatef {
	my ($self, $move) = @_;

	if ($self->ywidth <= 3) {
		return '1y';
	}

	return;
}

1;
