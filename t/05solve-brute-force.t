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

$cube->move("R");
my @solves = $solver->solve($cube, max_depth => 1);
my $num_solutions = scalar @solves;
my @wanted = ("R'");

is $num_solutions, 1, "one solution for R";
is_deeply \@solves, \@wanted, "found R' after R";

done_testing;
