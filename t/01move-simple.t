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

my $cube = Games::CuboidPuzzle->new;
use Games::CuboidPuzzle::Renderer::Simple;

my $renderer = Games::CuboidPuzzle::Renderer::Simple->new;

my ($got, $wanted);

$cube->move('3x2');
$got = $renderer->render($cube);
$wanted = <<'EOF';
      B B G
      B B G
      B B G
O O O Y Y W R R R Y W W
O O O Y Y W R R R Y W W
O O O Y Y W R R R Y W W
      G G B
      G G B
      G G B
EOF
is $got, $wanted, 'after 3x2';

$cube->move('3z3');
$got = $renderer->render($cube);
$wanted = <<'EOF';
      R R R
      B B G
      B B G
G O O Y Y W R R B Y Y Y
B O O Y Y W R R G W W W
B O O Y Y W R R G W W W
      G G B
      G G B
      O O O
EOF

done_testing;

1;
