#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Notation::Conventional;

use strict;
use v5.10;

use base qw(Games::CuboidPuzzle::Notation::WCA);

use Locale::TextDomain qw(1.32);
use Games::CuboidPuzzle;

sub parse {
	my ($self, $original, $cube) = @_;

	my $translated;
	my $move;
	my %slice_moves = (
		"M" => '2x3',
		"M2" => '2x2',
		"M'" => '2x1',
		"S" => '2y1',
		"S2" => '2y2',
		"S3" => '2y3',
		"E" => '2z3',
		"E2" => '2z2',
		"E'" => '2z1',
	);
	if ($original =~ /^([lrfbud])([2'])?$/) {
		my $face = uc $1;
		$move = $face . $2 . 'w';
	} elsif (exists $slice_moves{$original}
	         && 3 == $cube->xwidth
	         && 3 == $cube->ywidth
	         && 3 == $cube->zwidth) {
		return $slice_moves{$original};
	} else {
		$move = $original;
	}

	my $translated = eval { $self->SUPER::parse($move, $cube) };
	if ($@) {
		require Carp;
		Carp::croak(__x("invalid move '{move}'", move => $move));
	}

	return $translated;
}

sub translate {
	# FIXME! The cube should be injected.
	my ($self, $move, $cube) = @_;

	my @moves = $self->SUPER::translate($move, $cube);

	if (1 == @moves) {
		if ($moves[0] =~ /^([LRFBUD])(.*)w$/) {
			$moves[0] = lc $1 . $2;
		}
	} elsif (3 == $cube->xwidth
	         && 3 == $cube->ywidth
			 && 3 == $cube->zwidth
			 && $move =~ /^2[xyz][123]$/i) {
		my %slice_mappings = (
			'2x1' => "M'",
			'2x2' => "M2",
			'2x3' => "M",
			'2y1' => "S",
			'2y2' => "S2",
			'2y3' => "S'",
			'2z1' => "E'",
			'2z2' => "E2",
			'2z3' => "E",
		);
		$move = lc $move;
		@moves = ("$slice_mappings{$move}");
	}

	return @moves;
}

1;
