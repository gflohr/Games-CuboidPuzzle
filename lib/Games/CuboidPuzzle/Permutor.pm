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
		__skip_duplicates => 1,
	};

	bless $self, $class;
}

sub skipDuplicates {
	my ($self, $value) = @_;

	if (@_ == 2) {
		$self->{__skip_duplicates} = $value;
	}

	return $self->{__skip_duplicates};
}

sub permute {
	my ($self, $max_depth, $callback) = @_;

	local $";
	my $state = "@{$self->{__cube}->{__state}}";
	my %seen = ($state => 'initial');
	$self->__doPermute(1, $max_depth, [], $callback, \%seen);

	return $self;
}

sub __permuteFirst {
	my ($self, $max_depth, $path, $callback, $seen) = @_;

	my $depth = 1;

	local $";
	my $cube = $self->{__cube};
	my $done;
	my $skip_duplicates = $self->{__skip_duplicates};
	foreach my $move (sort keys %{$self->{__supported}}) {
		my ($coord, $layer, $turns) = @{$self->{__supported}->{$move}};
		# Special for finding interesting last layer moves.
		next if $coord != 1;
		next if $layer != 0;

		if (@$path) {
			my $last = $path->[-1];
			if ($last->[0] == $coord && $last->[1] eq $layer) {
				next;
			}
		}

		push @$path, [$coord, $layer, 1, $turns];
		$cube->ultraFastMove($coord, $layer, 1, $turns);

		my $state = "@{$cube->{__state}}";
		if (!$skip_duplicates || !exists $seen->{$state} || $seen->{$state} > $depth) {
			$seen->{$state} = $depth;
			if ($depth == $max_depth) {
				$callback->($path) or $done = 1;
			} else {
				$self->__doPermute($depth + 1, $max_depth, $path, $callback, $seen)
					or $done = 1;
			}
		}

		pop @$path;
		$cube->fastMove($coord, $layer, 1, 4 - $turns);

		return if $done;
	}

	return $self;
}

sub __doPermute {
	my ($self, $depth, $max_depth, $path, $callback, $seen) = @_;

	local $";
	my $cube = $self->{__cube};
	my $done;
	my $skip_duplicates = $self->{__skip_duplicates};
	foreach my $move (sort keys %{$self->{__supported}}) {
		my ($coord, $layer, $turns) = @{$self->{__supported}->{$move}};
		if (@$path) {
			my $last = $path->[-1];
			if ($last->[0] == $coord && $last->[1] eq $layer) {
				next;
			}
		}

		push @$path, [$coord, $layer, 1, $turns];
		$cube->ultraFastMove($coord, $layer, 1, $turns);

		my $state = "@{$cube->{__state}}";
		if (!$skip_duplicates || !exists $seen->{$state} || $seen->{$state} > $depth) {
			$seen->{$state} = $depth;
			if ($depth == $max_depth) {
				$callback->($path) or $done = 1;
			} else {
				$self->__doPermute($depth + 1, $max_depth, $path, $callback, $seen)
					or $done = 1;
			}
		}

		pop @$path;
		$cube->fastMove($coord, $layer, 1, 4 - $turns);

		return if $done;
	}

	return $self;
}

sub translatePath {
	my ($self, $path) = @_;

	my @solve = map { $self->translateMove($_) } @$path;
	return wantarray ? @solve : join ' ', @solve;
}

sub translateMove {
	my ($self, $move) = @_;

	my ($coord, $layer, $width, $turns) = @$move;
	$width = '' if 1 == $width;
	my $layer_id = chr($layer + ord('x'));
	return $self->{__cube}->translateMove("$coord$layer_id$width$turns");
}

1;
