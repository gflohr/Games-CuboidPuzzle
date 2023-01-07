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
my $p = Games::CuboidPuzzle::Permutor->new($cube);

my $count = 0;
$p->permute(1, sub { ++$count; return 1 });
is $count, 27, "depth 1";
ok $cube->conditionSolved, "solved after depth 1";

$count = 0;
$p->permute(2, sub { ++$count; return 1 });
is $count, 564, "depth 2";
ok $cube->conditionSolved, "solved after depth 2";

done_testing;
