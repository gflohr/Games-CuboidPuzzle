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
use Games::CuboidPuzzle::MoveTranslator::Conventional;

my %tests = (
	'1x21' => "l'",
	'1x22' => "l2",
	'1x23' => "l",
	'1y21' => "f",
	'1y22' => "f2",
	'1y23' => "f'",
	'1z21' => "d'",
	'1z22' => "d2",
	'1z23' => "d",
	'2x1' => "M'",
	'2x2' => "M2",
	'2x3' => "M",
	'2y1' => "S",
	'2y2' => "S2",
	'2y3' => "S'",
	'2z1' => "E'",
	'2z2' => "E2",
	'2z3' => "E",
);

my $cube = Games::CuboidPuzzle->new;

foreach my $move (sort keys %tests) {
	my @got = Games::CuboidPuzzle::MoveTranslator::Conventional->translate($move, $cube);
	is scalar @got, 1, "$move triggered multiple moves";
	is $got[0], $tests{$move}, "$move eq $tests{$move}";
}

done_testing;
