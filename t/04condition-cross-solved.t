# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

use strict;
use v5.10;

use Test::More;

use List::Util qw(pairs);

use Games::CuboidPuzzle;
use Games::CuboidPuzzle::Permutor;

my $cube = Games::CuboidPuzzle->new;
$cube->move("R2", "F2");
ok !$cube->conditionCrossSolved(2);
$cube->move("U", "F2", "U2", "R2");
ok !$cube->conditionCrossSolved(2);
$cube->move("F2", "U'", "R2", "U", "F2");
ok $cube->conditionCrossSolved(2);

my $cube = Games::CuboidPuzzle->new;
$cube->move("R", "U", "R'", "U'", "L'", "U'", "L", "U");
ok $cube->conditionAnyCrossSolved;

$cube->move("R2", "U", "F2", "U'", "R2");
ok !$cube->conditionAnyCrossSolved;

$cube->move("R2", "U", "F2", "U'", "R2");
ok $cube->conditionAnyCrossSolved;

done_testing;
