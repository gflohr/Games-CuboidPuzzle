#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Renderer::Simple;

use strict;
use v5.10;

use base qw(Games::CuboidPuzzle::Renderer);

sub render {
	my ($self, $cube) = @_;

	my $x = $cube->xwidth;
	my $y = $cube->ywidth;
	my $z = $cube->zwidth;
	my $colors = $cube->colors;
	my @state = $cube->state;

	my $dump = '';

	foreach my $row (0 .. $z - 1) {
		$dump .= ' ' x (2 * $z);

		foreach my $col (0 .. $x - 1) {
			$dump .= $state[$row * $x + $col] . ' ';
		}
		chop $dump;
		$dump .= "\n";
	}


	foreach my $row (0 .. $y - 1) {
		foreach my $col (0 .. 2 * ($x + $z) - 1) {
			$dump .= $state[$x * $z + 2 * $row * ($x + $z) + $col] . ' ';
		}
		chop $dump;
		$dump .= "\n";
	}

	foreach my $row (0 .. $z - 1) {
		$dump .= ' ' x (2 * $z);

		foreach my $col (0 .. $x - 1) {
			$dump .= $state[$x * $z + 2 * $y * ($x + $z) + $row * $x + $col] . ' ';
		}
		chop $dump;
		$dump .= "\n";
	}

	return $dump;
}

1;
