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

use base qw(Games::CuboidPuzzle::MoveTranslator);

use Locale::TextDomain qw(1.32);
use Games::CuboidPuzzle;

sub parse {
	my ($self, $move, $cube) = @_;

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
	$turns = 4 - $turns if $face =~ /^L$/;
	my %face2coord = (
		L => '1x',
		R => $cube->xwidth . 'x',
		F => '1y',
		B => $cube->ywidth . 'y',
		U => '3z',
		D => $cube->ywidth . 'z',
	);

	return "$face2coord{$face}$width$turns";
}

1;
