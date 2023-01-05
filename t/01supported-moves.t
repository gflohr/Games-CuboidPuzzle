# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

use strict;

use Test::More;

use List::Util qw(pairs);

use Games::CuboidPuzzle;

my $cube = Games::CuboidPuzzle->new;
my @supported = sort $cube->supportedMoves;
my @wanted = sort (
	"x", "x2", "x'",
	"y", "y2", "y'",
	"z", "z2", "z'",
	"L", "L2", "L'",
	"M", "M2", "M'",
	"R", "R2", "R'",
	"F", "F2", "F'",
	"S", "S2", "S'",
	"B", "B2", "B'",
	"D", "D2", "D'",
	"E", "E2", "E'",
	"U", "U2", "U'",
);

is_deeply \@supported, \@wanted, 'supportedMoves';

done_testing;

1;
