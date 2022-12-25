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

my @state = (0 .. 9, 'A' .. 'Z', 'a' .. 'r');

my %tests = (
	'0x1' => {
		'1x1' => '1x1',
		'1x2' => '1x2',
		'1x3' => '1x3',
		'1y1' => '1z1',
		'1y2' => '1z2',
		'1y3' => '1z3',
		#'1z1' => '1y3',
		'2x1' => '2x1',
		'2x2' => '2x2',
		'2x3' => '2x3',
		'3x1' => '3x1',
		'3x2' => '3x2',
		'3x3' => '3x3',
	},
	'0x2' => {
		'1x1' => '1x1',
		'1x2' => '1x2',
		'1x3' => '1x3',
		'2x1' => '2x1',
		'2x2' => '2x2',
		'2x3' => '2x3',
		'3x1' => '3x1',
		'3x2' => '3x2',
		'3x3' => '3x3',
	},
	'0x3' => {
		'1x1' => '1x1',
		'1x2' => '1x2',
		'1x3' => '1x3',
		'2x1' => '2x1',
		'2x2' => '2x2',
		'2x3' => '2x3',
		'3x1' => '3x1',
		'3x2' => '3x2',
		'3x3' => '3x3',
	},
);

foreach my $rotation (sort keys %tests) {
	foreach my $move (sort keys %{$tests{$rotation}}) {
		my $rotated_mover = Games::CuboidPuzzle->new(
			state => [@state],
		);
		my $rotated_move = $rotated_mover->rotateMove($move, $rotation);
		$rotated_mover->move($rotation);
		$rotated_mover->move($rotated_move);
		my $opposite_rotation = $rotation;
		$opposite_rotation =~ s/([123])$/4 - $1/e;
		$rotated_mover->move($opposite_rotation);
		my $single_mover = Games::CuboidPuzzle->new(
			state => [@state],
		);
		$single_mover->move($move);
		my $got = "\n" . $single_mover->render;
		my $wanted = "\n" . $rotated_mover->render;
		is $got, $wanted, "$move after $rotation == $rotated_move";
	}
}

done_testing;

1;