#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Command::Cross;

use strict;
use v5.10;

use Locale::TextDomain 'Games-CuboidPuzzle';
use List::MoreUtils qw(uniq);

use base qw(Games::CuboidPuzzle::Command);

use Games::CuboidPuzzle;
use Games::CuboidPuzzle::Permutor;

sub _getDefaults { rotate => 1 }

sub _getOptionSpecs {
	color => 'c|color=s',
	rotate => 'rotate!',
}

sub _run {
	my ($self, $args, $global_options, %options) = @_;

	my $cube = $self->_cube($global_options);

	my @moves = $self->_expandMoves($args);
	foreach my $move (@moves) {
		$cube->move($move);
	}

	if (defined $options{color}) {
		my @exists = grep { $_ eq $options{color} } $cube->state;
		if (!@exists) {
			Games::CuboidPuzzle::CLI->commandUsageError(
				__x("cube has no color '{color}'",
					color => $options{color}));
		}
	}

	my @solves = defined $options{color} ?
		$self->__solveCross($cube, %options)
		: $self->__solveAnyCross($cube, %options);

	my %solves;
	foreach my $solve (@solves) {
		$cube->move(@$solve);
		foreach my $layer (0 .. 5) {
			next if !$cube->conditionCrossSolved($layer);
			my @crossIndices = $cube->crossIndicesFlattened($layer);
			my @state = $cube->state;
			my @crossColors = @state[@crossIndices];
			my $color = $crossColors[0];
			$solves{$color} ||= [];
			push @{$solves{$color}}, $solve;
		}

		$cube->unmove(@$solve);
	}

	foreach my $color (sort keys %solves) {
		foreach my $solve (sort @{$solves{$color}}) {
			my @solve = @$solve;
			@solve = $cube->rotateMovesToBottom($color, @solve)
				if $options{rotate};
			say __x("color {color}: {solve}",
				color => $color,
				solve => join ' ', @solve,
			);
		}
	}

	return $self;
}

sub __solveAnyCross {
	my ($self, $cube, %options) = @_;

	if ($cube->conditionAnyCrossSolved) {
		Games::CuboidPuzzle::CLI->commandUsageError(solve
			=> __"the cube has already a solved cross");
	}

	my @crossIndicesFlattened = map { [$cube->crossIndicesFlattened($_)] } (0 .. 5);

	my @solves;
	my $depth = 0;
	my $p = Games::CuboidPuzzle::Permutor->new($cube);
	while (1) {
		++$depth;
		last if exists $options{max_depth} && $depth > $options{max_depth};

		$p->permute($depth, sub {
			my ($path) = @_;

			LAYER: foreach my $i (0 .. 5) {
				my @colors = uniq @{$self->{__state}}[@{$crossIndicesFlattened[$i]}];
				next LAYER if $#colors;

				my $edge_indices = $self->{__edgeIndicesFlattened}->[$i];
				foreach my $face (0 .. 2) {
					@colors = uniq @{$self->{__state}}[@{$edge_indices->[$face]}];
					next LAYER if $#colors;
				}

				push @solves, [$p->translatePath($path)];
				last LAYER;
			}

			return 1;
		});

		last if @solves;
	}

	return @solves;
}

sub __solveCross {
	my ($self, $cube, %options) = @_;

	my $color = $options{color};
	my $layer = $cube->findLayer($color)
		or Games::CuboidPuzzle::CLI->commandUsageError(cross
			=> __x("this cube has no color '{color}'", color => $color));

	if ($cube->conditionCrossSolved($options{color})) {
		Games::CuboidPuzzle::CLI->commandUsageError(cross
			=> __"this cross is already solved on this cube");
	}

	my @crossIndicesFlattened = $cube->crossIndicesFlattened($layer);
	my $edge_indices = $cube->{__edgeIndicesFlattened}->[$layer];

	my @solves;
	my $depth = 0;
	my $p = Games::CuboidPuzzle::Permutor->new($cube);
	while (1) {
		++$depth;
		last if exists $options{max_depth} && $depth > $options{max_depth};

		$p->permute($depth, sub {
			my ($path) = @_;

			my @colors = uniq @{$cube->{__state}}[@crossIndicesFlattened];
			return 1 if $#colors;

			foreach my $face (0 .. 2) {
				@colors = uniq @{$cube->{__state}}[@{$edge_indices->[$face]}];
				return 1 if $#colors;
			}

			push @solves, [$p->translatePath($path)];

			return 1;
		});

		last if @solves;
	}

	return @solves;
}

1;

=head1 NAME

cuboid cross - Find solution to solve a cross

=head1 SYNOPSIS

    cuboid cross [<global options>] [--color=COLOR] MOVES...

=head1 DESCRIPTION

The command applies B<MOVES> to the specified cube and then tries to solve
a cross.

Each move argument is automatically split at spaces and tabs.  As a convenience,
you may replace the single quote character "'" with the lowercase letter i.

The cross must have all adjacent edges oriented and at the correct position.

=head1 OPTIONS

=over 4

=item -c, --colour=COLOUR, --color=COLOR

Try to solve only the cross of colour COLOuR (usually one of W, Y, R, O, G, or B).

Note that sometimes the same sequence of moves solves multiple crosses.  In
such cases, all solutions will be displayed, not only the one for the
specified colour.

=item --rotate

Rotate the cube so that the solved colour is at the bottom.  This is the default
behaviour.

=item --no-rotate

Do not rotate the cube.

=item -h, --help

Show this help page and exit.

=back

=head1 SEE ALSO

L<Games::CuboidPuzzle::Solver::BruteForce>, L<Games::CuboidPuzzle>, cuboid(1),
perl(1)
