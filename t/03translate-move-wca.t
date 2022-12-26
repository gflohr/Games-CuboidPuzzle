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
);

my $cube = Games::CuboidPuzzle->new(
	xwidth => 5,
	ywidth => 5,
	zwidth => 4,
);

foreach my $move (sort keys %tests) {
	my @got = Games::CuboidPuzzle::MoveTranslator::WCA->translate($move, $cube);
	is scalar @got, 1, "$tests{$move} triggered multiple moves";
	is $got[0], $tests{$move}, "$move eq $tests{$move}";
}

done_testing;
