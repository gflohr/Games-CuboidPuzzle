#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Permutor;

use strict;
use v5.10;

sub new {
	my ($class, $cube) = @_;

	my @supported = $cube->supportedMoves;
	my %supported_internal;
	foreach my $move (@supported) {
		my $internal = $cube->parseMove($move);
		my ($coord, $layer, $width, $turns) = $cube->parseInternalMove($internal);
		next if 0 == $coord; # Cube rotation.
		$supported_internal{$internal} = [$coord, $layer, $turns];
	}
	my $self = {
		__cube => $cube,
		__supported => \%supported_internal,
	};

	bless $self, $class;
}

sub permute {
	my ($self, $max_depth, $callback) = @_;

	$self->__doPermute(1, $max_depth, $callback);

	return $self;
}

sub __doPermute {
	my ($self, $depth, $max_depth, $callback) = @_;

	my $cube = $self->{__cube};
	foreach my $move (keys %{$self->{__supported}}) {
		my ($coord, $layer, $turns) = @{$self->{__supported}->{$move}};

		$cube->fastMove($coord, $layer, $turns);

		if ($depth == $max_depth) {
			$callback->();
		} else {
			$self->__doPermute($depth + 1, $max_depth, $callback);
		}
		$cube->fastMove($coord, $layer, 4 - $turns);
	}

	return $self;
}

1;
