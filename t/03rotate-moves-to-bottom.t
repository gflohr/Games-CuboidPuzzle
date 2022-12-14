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
	["F", "W", "x2 y R"],
	["R U R' U'", "B", "x y F R F' R'"],
	["R S", "O", "z' y U M z'"]
);

my $cube = Games::CuboidPuzzle->new;

foreach my $test (@tests) {
	my ($moves, $colour, $wanted) = @$test;
	my @moves = split / +/, $moves;
	my $cube = Games::CuboidPuzzle->new;
	my @got = $cube->rotateMovesToBottom($colour, @moves);
	my @wanted = split / +/, $wanted;
	is_deeply \@got, \@wanted, "'$moves' rotated to face '$colour'";
	ok $cube->conditionSolved,
		"cube solved again after '$moves' rotate to face '$colour'";
}

done_testing;
