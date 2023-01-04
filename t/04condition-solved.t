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

my $cube = Games::CuboidPuzzle->new;

ok $cube->conditionSolved, "initial";
$cube->move("x");
ok $cube->conditionSolved, "after x";
$cube->move("y");
ok $cube->conditionSolved, "after y";
$cube->move("z");
ok $cube->conditionSolved, "after z";
$cube->move("R");
ok !$cube->conditionSolved, "after R";
$cube->move("R'");
ok $cube->conditionSolved, "after R'";

done_testing;
