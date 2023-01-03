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
use Games::CuboidPuzzle::MoveParser::Conventional;

my %tests = (
	"l" => '1x23',
	"r" => '2x21',
	"f" => '1y21',
	"b" => '2y23',
	"u" => '2z21',
	"d" => '1z23',
	"l2" => '1x22',
	"r2" => '2x22',
	"f2" => '1y22',
	"b2" => '2y22',
	"u2" => '2z22',
	"d2" => '1z22',
	"l'" => '1x21',
	"r'" => '2x23',
	"f'" => '1y23',
	"b'" => '2y21',
	"u'" => '2z23',
	"d'" => '1z21',
	"M" => '2x3',
	"M2" => '2x2',
	"M'" => '2x1',
	"S" => '2y1',
	"S2" => '2y2',
	"S3" => '2y3',
	"E" => '2z3',
	"E2" => '2z2',
	"E'" => '2z1',
	# All WCA moves must also work.
	"L" => '1x3',
	"Lw" => '1x23',
	"L2" => '1x2',
	"L2w" => '1x22',
	"L'" => '1x1',
	"L'w" => '1x21',
	"R" => '3x1',
	"Rw" => '2x21',
	"R2" => '3x2',
	"R2w" => '2x22',
	"R'" => '3x3',
	"R'w" => '2x23',
	"F" => '1y1',
	"Fw" => '1y21',
	"F2" => '1y2',
	"F2w" => '1y22',
	"F'" => '1y3',
	"F'w" => '1y23',
	"B" => '3y3',
	"Bw" => '2y23',
	"B2" => '3y2',
	"B2w" => '2y22',
	"B'" => '3y1',
	"B'w" => '2y21',
	"U" => '3z1',
	"Uw" => '2z21',
	"U2" => '3z2',
	"U2w" => '2z22',
	"U'" => '3z3',
	"U'w" => '2z23',
	"D" => '1z3',
	"Dw" => '1z23',
	"D2" => '1z2',
	"D2w" => '1z22',
	"D'" => '1z1',
	"D'w" => '1z21',
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

my $cube = Games::CuboidPuzzle->new;

ok 1;
foreach my $move (sort keys %tests) {
	my @got = Games::CuboidPuzzle::MoveParser::Conventional->parse($move, $cube);
	is scalar @got, 1, "$move triggered multiple moves";
	is $got[0], $tests{$move}, "$move eq $tests{$move}";
}

done_testing;
