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
use Games::CuboidPuzzle::Permutor;

my $cube = Games::CuboidPuzzle->new;
my $p = Games::CuboidPuzzle::Permutor->new($cube);

my $count = 0;
$p->permute(1, sub { ++$count });
is $count, 27, "depth 1";

done_testing;
