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

my @tests = (
	['0x1', 0, 0, 1, 1],
	['0x2', 0, 0, 1, 2],
	['0x3', 0, 0, 1, 3],
	['0y1', 0, 1, 1, 1],
	['0y2', 0, 1, 1, 2],
	['0y3', 0, 1, 1, 3],
	['0z1', 0, 2, 1, 1],
	['0z2', 0, 2, 1, 2],
	['0z3', 0, 2, 1, 3],
	['1x1', 1, 0, 1, 1],
	['1x2', 1, 0, 1, 2],
	['1x3', 1, 0, 1, 3],
	['1y1', 1, 1, 1, 1],
	['1y2', 1, 1, 1, 2],
	['1y3', 1, 1, 1, 3],
	['1z1', 1, 2, 1, 1],
	['1z2', 1, 2, 1, 2],
	['1z3', 1, 2, 1, 3],
	['2x1', 2, 0, 1, 1],
	['2x2', 2, 0, 1, 2],
	['2x3', 2, 0, 1, 3],
	['2y1', 2, 1, 1, 1],
	['2y2', 2, 1, 1, 2],
	['2y3', 2, 1, 1, 3],
	['2z1', 2, 2, 1, 1],
	['2z2', 2, 2, 1, 2],
	['2z3', 2, 2, 1, 3],
	['3x1', 3, 0, 1, 1],
	['3x2', 3, 0, 1, 2],
	['3x3', 3, 0, 1, 3],
	['3y1', 3, 1, 1, 1],
	['3y2', 3, 1, 1, 2],
	['3y3', 3, 1, 1, 3],
	['3z1', 3, 2, 1, 1],
	['3z2', 3, 2, 1, 2],
	['3z3', 3, 2, 1, 3],
);

foreach my $test (@tests) {
	my ($move, $wanted_coord, $wanted_layer, $wanted_width, $wanted_turns)
		= @$test;
	my ($got_coord, $got_layer, $got_width, $got_turns)
		= Games::CuboidPuzzle->parseInternalMove($move);
	is $got_coord, $wanted_coord, "coord $move";
	is $got_layer, $wanted_layer, "layer $move";
	is $got_width, $wanted_width, "width $move";
	is $got_turns, $wanted_turns, "turns $move";
}

done_testing;

1;
