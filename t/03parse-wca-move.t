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
use Games::CuboidPuzzle::MoveParser::WCA;

my %tests = (
	"L" => '1x3',
	"Lw" => '1x23',
	"3Lw" => '1x33',
	"L'" => '1x1',
	"L'w" => '1x21',
	"3L'w" => '1x31',
	"R" => '4x1',
	"Rw" => '3x21',
	"3Rw" => '2x31',
	"R'" => '4x3',
	"R'w" => '3x23',
	"3R'w" => '2x33',
);

my $cube = Games::CuboidPuzzle->new(
	xwidth => 4,
	ywidth => 4,
	zwidth => 4,
);

foreach my $move (sort keys %tests) {
	my @got = Games::CuboidPuzzle::MoveParser::WCA->parse($move, $cube);
	is scalar @got, 1, "$move triggered multiple moves";
	is $got[0], $tests{$move}, "$move eq $tests{$move}";
}

done_testing;
