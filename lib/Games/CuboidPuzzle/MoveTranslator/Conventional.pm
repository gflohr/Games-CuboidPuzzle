#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::MoveTranslator::Conventional;

use strict;
use v5.10;

use base qw(Games::CuboidPuzzle::MoveTranslator::WCA);

use Locale::TextDomain qw(1.32);
use Games::CuboidPuzzle;

sub translate {
	# FIXME! The cube should be injected.
	my ($self, $move, $cube) = @_;

	my @moves = $self->SUPER::translate($move, $cube);

	if (1 == @moves) {
		if ($moves[0] =~ /^([LRFBUD])(.*)w$/) {
			$moves[0] = lc $1 . $2;
		}
	}

	return @moves;
}

1;
