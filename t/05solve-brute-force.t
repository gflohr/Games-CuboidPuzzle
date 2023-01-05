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
use Games::CuboidPuzzle::Solver::BruteForce;

my $cube = Games::CuboidPuzzle->new;
my $solver = Games::CuboidPuzzle::Solver::BruteForce->new;

my (@solves, $num_solutions, @wanted);

$cube->move("R");
@solves = $solver->solve($cube, max_depth => 1);
$num_solutions = scalar @solves;
@wanted = (["R'"]);
is $num_solutions, 1, "one solution for R";
is_deeply \@solves, \@wanted, "found R' after R";
$cube->move(@{$solves[0]});
ok $cube->conditionSolved, "solution for R works";

$cube->move("R2", "F2");
@solves = sort $solver->solve($cube, max_depth => 2);
$num_solutions = scalar @solves;
@wanted = (["F2", "R2"]);
is $num_solutions, 1, "one solution for R2 F2";
is_deeply \@solves, \@wanted, "found F2 R2 after R2 F@";
$cube->move(@{$solves[0]});
ok $cube->conditionSolved, "solution for R2 F2 works";

done_testing;
