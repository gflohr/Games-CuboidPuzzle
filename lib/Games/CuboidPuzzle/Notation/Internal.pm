#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Notation::Internal;

use strict;
use v5.10;

use base qw(Games::CuboidPuzzle::Notation);

sub parse {
	my ($self, $original, $cube) = @_;

	return $original;
}

sub translate {
	my ($self, $move) = @_;

	return $move;
}

1;
