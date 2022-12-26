#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::MoveTranslator::WCA;

use strict;
use v5.10;

use base qw(Games::CuboidPuzzle::MoveTranslator);

use Locale::TextDomain qw(1.32);
use Games::CuboidPuzzle;

my %internal2wca = (
	x => [qw(L R)],
	y => [qw(F B)],
	z => [qw[D U]],
);

my %internal2wca_rotation = (
	'0x1' => "x",
	'0x2' => "x2",
	'0x3' => "x'",
	'0y1' => "z",
	'0y2' => "z2",
	'0y3' => "z'",
	'0z1' => "y",
	'0z2' => "y",
	'0z3' => "y'",
);

my %wca_turns = (
	L => ["'", 2, ""],
	R => ["", 2, "'"],
	F => ["", 2, "'"],
	B => ["'", 2, ""],
	U => ["", 2, "'"],
	D => ["'", 2, ""],
);

sub translate {
	# FIXME! The cube should be injected.
	my (undef, $move, $cube) = @_;

	my ($coord, $layer, $width, $turns) = Games::CuboidPuzzle->parseMove($move);
	if (!defined $coord) {
		die __x("invalid move '{move}'\n", move => $move);
	}

	my $width_method = $layer . 'width';
	my $cube_width = $cube->$width_method;

	my @wca;

	if ($coord == 0) {
		# Normalize move.
		$move = "0$layer$turns";
		push @wca, $internal2wca_rotation{$move};
	} elsif ($coord == 1 || $coord == $cube_width) {
		my $wca_layer = $internal2wca{$layer}->[$coord == $cube_width];
		my $wca_move = $wca_layer . $wca_turns{$wca_layer}->[$turns - 1];
		$wca_move .= 'w' if $width > 1;
		$wca_move = $width . $wca_move if $width > 2;
		push @wca, $wca_move;
	} else {
		die "inner block moves not yet supported";
	}

	return @wca;
}

1;
