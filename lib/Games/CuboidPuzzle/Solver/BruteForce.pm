#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Solver::BruteForce;

use strict;
use v5.10;

use base qw(Games::CuboidPuzzle::Solver);

sub solve {
	my ($self, $cube) = @_;

	my %seen;

	my @supported = $cube->supportedMoves;
	my @tries;
	my %seen;
	foreach my $move (@supported) {
		my ($internal_move) = $cube->parseMove($move);
		my ($coord, $layer, $width, $turns) = $cube->parseInternalMove($internal_move);
		next if !$coord;
		next if $width != 1;
		push @tries, [
			$internal_move,
			[$coord, $layer, $width, $turns],
			[$coord, $layer, $width, 4 - $turns],
		];
	}

	my $depth = 0;
	while (1) {
		my @solves = $self->__solve($cube, ++$depth, \@tries, \%seen) or next;
	}

	# Not reached.
}

sub __solve {
	my ($self, $cube, $depth, $tries, $seen) = @_;

	my @path = (0 .. $depth - 1);
	while ($path[0] < $depth) {

	}

	return;
}

sub __increasePath {
	my ($self, $path, $items) = @_;

	my $i;
	while ($i < @$path) {
		return $path if ++$path->[$i] < $items;
		$path->[$i++] = 0;
	}

	return;

}

1;
