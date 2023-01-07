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
	["F", "W", "x2 B"],
	["R U R' U'", "B", "x R B R' B'"],
	#["R S", "O", "z' U S z'"]
);

my $cube = Games::CuboidPuzzle->new;

foreach my $test (@tests) {
	my ($moves, $color, $wanted) = @$test;
	my @moves = split / +/, $moves;
	my $cube = Games::CuboidPuzzle->new;
	my @got = $cube->rotateMovesToBottom($color, @moves);
	my @wanted = split / +/, $wanted;
	is_deeply \@got, \@wanted, "'$moves' rotated to face '$color'";
	ok $cube->conditionSolved,
		"cube solved again after '$moves' rotate to face '$color'";
}

done_testing;
