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

sub _getDefaults { }

sub _getOptionSpecs {}

sub _run {
	my ($self, $args, $global_options, %options) = @_;

	my $cube = $self->_cube($global_options);

	my @moves = $self->_expandMoves($args);
	foreach my $move (@moves) {
		$cube->move($move);
	}

	my @solves = $self->__solveAnyCross($cube, %options);

	foreach my $solve (@solves) {
		say join ' ', @$solve;
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

			foreach my $i (0 .. 5) {
				my @colors = uniq @{$cube->{__state}}[@{$crossIndicesFlattened[$i]}];
				if (@colors == 1) {
					push @solves, [$p->translatePath($path)];
					last;
				}
			}

			return 1;
		});

		last if @solves;
	}

	return @solves;
}

1;

=head1 NAME

cuboid solve - Show solution to a scrambled

=head1 SYNOPSIS

    cuboid solve [<global options>] [--solver=SOLVER] MOVES...

=head1 DESCRIPTION

The command applies B<MOVES> to the specified cube and then tries to solve it
using the specified strategy.

Each move argument is automatically split at spaces and tabs.  As a convenience,
you may replace the single quote character "'" with the lowercase letter i.

=head1 OPTIONS

=over 4

=item -s, --solver=SOLVER

Use the specified solver, defaults to C<BRUTE_FORCE>.

=item -h, --help

Show this help page and exit.

=back

=head1 SEE ALSO

L<Games::CuboidPuzzle::Solver::BruteForce>, L<Games::CuboidPuzzle>, cuboid(1),
perl(1)
