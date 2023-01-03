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
use Games::CuboidPuzzle::Notation::WCA;

my %tests = (
	"L" => '1x3',
	"Lw" => '1x23',
	"3Lw" => '1x33',
	"L2" => '1x2',
	"L2w" => '1x22',
	"3L2w" => '1x32',
	"L'" => '1x1',
	"L'w" => '1x21',
	"3L'w" => '1x31',
	"R" => '4x1',
	"Rw" => '3x21',
	"3Rw" => '2x31',
	"R2" => '4x2',
	"R2w" => '3x22',
	"3R2w" => '2x32',
	"R'" => '4x3',
	"R'w" => '3x23',
	"3R'w" => '2x33',
	"F" => '1y1',
	"Fw" => '1y21',
	"3Fw" => '1y31',
	"F2" => '1y2',
	"F2w" => '1y22',
	"3F2w" => '1y32',
	"F'" => '1y3',
	"F'w" => '1y23',
	"3F'w" => '1y33',
	"B" => '4y3',
	"Bw" => '3y23',
	"3Bw" => '2y33',
	"B2" => '4y2',
	"B2w" => '3y22',
	"3B2w" => '2y32',
	"B'" => '4y1',
	"B'w" => '3y21',
	"3B'w" => '2y31',
	"U" => '4z1',
	"Uw" => '3z21',
	"3Uw" => '2z31',
	"U2" => '4z2',
	"U2w" => '3z22',
	"3U2w" => '2z32',
	"U'" => '4z3',
	"U'w" => '3z23',
	"3U'w" => '2z33',
	"D" => '1z3',
	"Dw" => '1z23',
	"3Dw" => '1z33',
	"D2" => '1z2',
	"D2w" => '1z22',
	"3D2w" => '1z32',
	"D'" => '1z1',
	"D'w" => '1z21',
	"3D'w" => '1z31',
	"x" => '0x1',
	"x2" => '0x2',
	"x'" => '0x3',
	"z" => '0y1',
	"z2" => '0y2',
	"z'" => '0y3',
	"y" => '0z1',
	"y2" => '0z2',
	"y'" => '0z3',
);

my $cube = Games::CuboidPuzzle->new(
	xwidth => 4,
	ywidth => 4,
	zwidth => 4,
);

foreach my $move (sort keys %tests) {
	my @got = Games::CuboidPuzzle::Notation::WCA->parse($move, $cube);
	is scalar @got, 1, "$move triggered multiple moves";
	is $got[0], $tests{$move}, "$move eq $tests{$move}";
}

done_testing;
