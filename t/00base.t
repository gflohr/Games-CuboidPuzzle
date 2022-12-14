# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

use Test::More;

my $package = 'Games::RubiksCube';

require_ok($package);

my $cube = $package->new;
ok $cube, 'constructor';
isa_ok($cube, $package, 'isa');

use Games::RubiksCube::Renderer::Simple;

my $renderer = Games::RubiksCube::Renderer::Simple->new;
my $got = $renderer->render($cube);
$wanted = <<'EOF';
      G G G 
      G G G 
      G G G 
O O O W W W R R R Y Y Y 
O O O W W W R R R Y Y Y 
O O O W W W R R R Y Y Y 
      B B B 
      B B B 
      B B B 
EOF

is $got, $wanted, 'simple renderer';

done_testing;

1;
