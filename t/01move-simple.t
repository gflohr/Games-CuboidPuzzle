# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

use Test::More;

use Games::CuboidPuzzle;

my $cube = Games::CuboidPuzzle->new;

$cube->move('3x2');

use Games::CuboidPuzzle::Renderer::Simple;

my $renderer = Games::CuboidPuzzle::Renderer::Simple->new;
my $got = $renderer->render($cube);
$wanted = <<'EOF';
      G G B 
      G G B 
      G G B 
O O O W W Y R R R W Y Y 
O O O W W Y R R R W Y Y 
O O O W W Y R R R W Y Y 
      B B G 
      B B G 
      B B G 
EOF

is $got, $wanted, 'simple renderer';

done_testing;

1;
