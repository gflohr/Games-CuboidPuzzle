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

use Games::CuboidPuzzle::Permutor;

sub solve {
	my ($self, $cube, %options) = @_;

	my $p = Games::CuboidPuzzle::Permutor->new($cube);
	my @solves;

	my $depth = 0;
	while (1) {
		++$depth;
		last if exists $options{max_depth} && $depth > $options{max_depth};

		$p->permute($depth, sub {
			my ($path) = @_;

			if ($cube->conditionSolved) {
				push @solves, $p->translatePath($path);
				warn $solves[-1];
				warn $cube->render;
				return !$options{find_all};
			}

			return 1;
		});

		last if @solves;
	}

	return @solves;
}

1;
