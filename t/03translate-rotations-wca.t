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
	'0x1' => "x",
	'0x2' => "x2",
	'0x3' => "x'",
	'0y1' => "z",
	'0y2' => "z2",
	'0y3' => "z'",
	'0z1' => "y",
	'0z2' => "y2",
	'0z3' => "y'",
);

my $cube = Games::CuboidPuzzle->new;

foreach my $move (sort keys %tests) {
	my @got = Games::CuboidPuzzle::Notation::WCA->translate($move, $cube);
	is scalar @got, 1, "$tests{$move} triggered multiple moves";
	is $got[0], $tests{$move}, "$move eq $tests{$move}";
}

done_testing;
