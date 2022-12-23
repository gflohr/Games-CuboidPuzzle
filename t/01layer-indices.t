# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

use strict;

use Test::More;

use Games::CuboidPuzzle;

my $cube = Games::CuboidPuzzle->new(xwidth => 4, ywidth => 3, zwidth => 2);

my $wanted0 = [[0 .. 3], [4 .. 7]];
my $layer0 = $cube->layerIndices('0');
is_deeply($layer0, $wanted0);
$layer0 = $cube->layerIndices('B');
is_deeply($layer0, $wanted0);

my $wanted1 = [[8 .. 9], [20 .. 21], [32 .. 33]];
my $layer1 = $cube->layerIndices('1');
is_deeply($layer1, $wanted1);
$layer1 = $cube->layerIndices('O');
is_deeply($layer1, $wanted1);

my $wanted2 = [[10 .. 13], [22 .. 25], [34 .. 37]];
my $layer2 = $cube->layerIndices('2');
is_deeply($layer2, $wanted2);
$layer2 = $cube->layerIndices('Y');
is_deeply($layer2, $wanted2);

my $wanted3 = [[14 .. 15], [26 .. 27], [38 .. 39]];
my $layer3 = $cube->layerIndices('3');
is_deeply($layer3, $wanted3);
$layer3 = $cube->layerIndices('R');
is_deeply($layer3, $wanted3);

my $wanted4 = [[16 .. 19], [28 .. 31], [40 .. 43]];
my $layer4 = $cube->layerIndices('4');
is_deeply($layer4, $wanted4);
$layer4 = $cube->layerIndices('W');
is_deeply($layer4, $wanted4);

my $wanted5 = [[44 .. 47], [48 .. 51]];
my $layer5 = $cube->layerIndices('5');
is_deeply($layer5, $wanted5);
$layer5 = $cube->layerIndices('G');
is_deeply($layer5, $wanted5);

done_testing;

1;
