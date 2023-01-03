#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::MoveParser::Conventional;

use strict;
use v5.10;

use base qw(Games::CuboidPuzzle::MoveParser::WCA);

use Locale::TextDomain qw(1.32);
use Games::CuboidPuzzle;

sub parse {
	my ($self, $original, $cube) = @_;

	my $translated;
	my $move;
	if ($original =~ /^([lrfbud])([2'])?$/) {
		my $face = uc $1;
		$move = $face . $2 . 'w';
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

1;
