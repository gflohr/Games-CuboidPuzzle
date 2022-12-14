# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

use strict;

use Test::More;

my $package = 'Games::CuboidPuzzle';

require_ok($package);

my $cube = $package->new;
ok $cube, 'constructor';
isa_ok($cube, $package, 'isa');

use Games::CuboidPuzzle::Renderer::Simple;

my $renderer = Games::CuboidPuzzle::Renderer::Simple->new;
my $got = $renderer->render($cube);
my $wanted = <<'EOF';
      B B B
      B B B
      B B B
O O O Y Y Y R R R W W W
O O O Y Y Y R R R W W W
O O O Y Y Y R R R W W W
      G G G
      G G G
      G G G
EOF

is $got, $wanted, 'simple renderer';

done_testing;

1;
