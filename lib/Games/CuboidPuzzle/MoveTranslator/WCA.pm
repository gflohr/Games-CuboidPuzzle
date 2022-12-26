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

my %wca_turns = (
	L => ["'", 2, ""],
	R => ["", 2, "'"],

);

sub translate {
	# FIXME! The cube should be injected.
	my (undef, $move, $cube) = @_;

	my ($coord, $layer, $width, $turns) = Games::CuboidPuzzle->parseMove($move);
	if (!defined $coord) {
		die __x("invalid move '{move}'\n", move => $move);
	}

	my $width_method = $layer . 'width';
	my $width = $cube->$width_method;

	my @wca;

	if ($coord == 0) {
		die "cube rotations not yet supported"
	} elsif ($coord == 1) {
		my $wca_layer = $internal2wca{$layer}->[0];
		my $wca_move = $wca_layer . $wca_turns{$wca_layer}->[$turns - 1];
		push @wca, $wca_move;
	} elsif ($coord == $width) {
		my $wca_layer = $internal2wca{$layer}->[1];
		my $wca_move = $wca_layer . $wca_turns{$wca_layer}->[$turns - 1];
		push @wca, $wca_move;
	} else {
		die "inner block moves not yet supported";
	}

	return @wca;
}

1;
