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
	'2x1' => ["L'w", "L"],
	'3x41' => ["6L'w", "Lw"]
);

my $cube = Games::CuboidPuzzle->new(
	xwidth => 9,
	ywidth => 9,
	zwidth => 9,
);

foreach my $move (sort keys %tests) {
	my @got = Games::CuboidPuzzle::Notation::WCA->translate($move, $cube);
	is scalar @got, 2, "$move triggered not exactly two moves";
	is $got[0], $tests{$move}->[0], "$move 1 eq $tests{$move}->[0]";
	is $got[1], $tests{$move}->[1], "$move 1 eq $tests{$move}->[1]";
}

done_testing;
