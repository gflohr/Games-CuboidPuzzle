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
	"x" => {
		"L'" => "L'",
		"M'" => "M'",
		"L" => "L",
		"F" => "U",
		"F2" => "U2",
		"F'" => "U'",
		"D'" => "F'",
		"D2" => "F2",
		"D" => "F",
	},
	"z" => {
		"L'" => "U'",
		"L2" => "U2",
		"L" => "U",
		"F" => "F",
		"F2" => "F2",
		"F'" => "F'",
		"D'" => "L'"
	},
	"y" => {
		"R" => "F",
		"F" => "L",
	},
	"y2" => {
		"L'" => "R'"
	},
	"y'" => {
		"L'" => "F'",
	}
);

foreach my $rotation (sort keys %tests) {
	foreach my $move (sort keys %{$tests{$rotation}}) {
		my $rotated_mover = Games::CuboidPuzzle->new(
			state => [@state],
		);
		my ($rotated_move, $garbage) =
			$rotated_mover->rotateMove($move, $rotation);
		ok !defined $garbage, "$move after $rotation produced garbage";
		is $rotated_move, $tests{$rotation}->{$move},
			"$move after $rotation == $rotated_move";
		$rotated_mover->move($rotation);
		$rotated_mover->move($rotated_move);
		my $opposite_rotation = $rotation;
		if ($opposite_rotation !~ s/'$//
			&& $opposite_rotation !~ /2$/) {
			$opposite_rotation .= "'";
		}
		$rotated_mover->move($opposite_rotation);
		my $single_mover = Games::CuboidPuzzle->new(
			state => [@state],
		);
		$single_mover->move($move);
		my $got = "\n" . $single_mover->render;
		my $wanted = "\n" . $rotated_mover->render;
		is $got, $wanted, "$move after $rotation vs $rotated_move";
	}
}

done_testing;

1;
