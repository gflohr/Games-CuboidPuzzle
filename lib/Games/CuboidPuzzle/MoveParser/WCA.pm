#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::MoveParser::WCA;

use strict;
use v5.10;

use base qw(Games::CuboidPuzzle::MoveParser);

use Locale::TextDomain qw(1.32);
use Games::CuboidPuzzle;

sub parse {
	my ($self, $move, $cube) = @_;

	if ($move =~ /^([xyz])([2'])?$/i) {
		my %rotations = (
			"x" => '0x1',
			"x2" => '0x2',
			"x'" => '0x3',
			"z" => '0y1',
			"z2" => '0y2',
			"z'" => '0y3',
			"y" => '0z1',
			"y2" => '0z2',
			"y'" => '0z3',
		);
		return $rotations{$move};
	}

	if ($move !~ /^([1-9][0-9]*)?([LRFBUD])([2'])?(w)?$/) {
		require Carp;
		Carp::croak(__x("invalid WCA move '{move}'", move => $move));
	}
	my ($width, $face, $direction, $wide_flag) = ($1, $2, $3, $4);
	if (!defined $width) {
		$width = $wide_flag ? 2 : 1;
	}
	$width = $width == 1 ? '' : $width;
	$direction //= '';
	my %dir2turns = (
		'' => 1,
		2 => 2,
		"'" => 3,
	);
	my $turns = $dir2turns{$direction};
	$turns = 4 - $turns if $face =~ /^[LBD]$/;
	my %face2coord = (
		L => '1x',
		R => $cube->xwidth . 'x',
		F => '1y',
		B => $cube->ywidth . 'y',
		U => $cube->ywidth . 'z',
		D => '1z',
	);
	my $position = $face2coord{$face};
	if ($width != '' && $position =~ /^([1-9][0-9]*)([xyz])$/ && $1 != 1) {
		my $coord = $1 - $width + 1;
		$position = "$coord$2";
	}

	return "$position$width$turns";
}

1;
