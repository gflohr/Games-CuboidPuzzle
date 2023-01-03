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
use Games::CuboidPuzzle::MoveTranslator::WCA;

my %tests = (
	'1x1' => "L'",
	'1x2' => "L2",
	'1x3' => "L",
	'1x21' => "L'w",
	'1x22' => "L2w",
	'1x23' => "Lw",
	'1x31' => "3L'w",
	'1x32' => "3L2w",
	'1x33' => "3Lw",
	'1y1' => "F",
	'1y2' => "F2",
	'1y3' => "F'",
	'1y21' => "Fw",
	'1y22' => "F2w",
	'1y23' => "F'w",
	'1y31' => "3Fw",
	'1y32' => "3F2w",
	'1y33' => "3F'w",
	'1z1' => "D'",
	'1z2' => "D2",
	'1z3' => "D",
	'1z21' => "D'w",
	'1z22' => "D2w",
	'1z23' => "Dw",
	'1z31' => "3D'w",
	'1z32' => "3D2w",
	'1z33' => "3Dw",
	'4x1' => "R",
	'4x2' => "R2",
	'4x3' => "R'",
	'3x21' => "Rw",
	'3x22' => "R2w",
	'3x23' => "R'w",
	'2x31' => "3Rw",
	'2x32' => "3R2w",
	'2x33' => "3R'w",
	'4y1' => "B'",
	'4y2' => "B2",
	'4y3' => "B",
	'3y21' => "B'w",
	'3y22' => "B2w",
	'3y23' => "Bw",
	'2y31' => "3B'w",
	'2y32' => "3B2w",
	'2y33' => "3Bw",
	'4z1' => "U",
	'4z2' => "U2",
	'4z3' => "U'",
	'3z21' => "Uw",
	'3z22' => "U2w",
	'3z23' => "U'w",
	'2z31' => "3Uw",
	'2z32' => "3U2w",
	'2z33' => "3U'w",
);

my $cube = Games::CuboidPuzzle->new(
	xwidth => 4,
	ywidth => 4,
	zwidth => 4,
);

foreach my $move (sort keys %tests) {
	my @got = Games::CuboidPuzzle::MoveTranslator::WCA->translate($move, $cube);
	is scalar @got, 1, "$move triggered multiple moves";
	is $got[0], $tests{$move}, "$move eq $tests{$move}";
}

done_testing;
