#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Command::Solve;

use strict;
use v5.10;

use Games::CuboidPuzzle;

use base qw(Games::CuboidPuzzle::Command);

use Locale::TextDomain 'Games-CuboidPuzzle';

sub _getDefaults { solver => 'brute_force' }

sub _getOptionSpecs {
	solver => 's|solver=s',
}

sub _run {
	my ($self, $args, $global_options, %options) = @_;

	my $cube = $self->_cube($global_options);

	my @moves = $self->_expandMoves($args);
	foreach my $move (@moves) {
		$cube->move($move);
	}

	if ($cube->conditionSolved) {
		Games::CuboidPuzzle::CLI->commandUsageError(solve
			=> __"the cube is already solved");
	}

	my $solver_id = ucfirst lc $options{solver};
	$solver_id =~ s/_(.)/uc $1/ge;

	my $solver_class = "Games::CuboidPuzzle::Solver::$solver_id";
	my $solver_module = $self->_class2module($solver_class);
	eval { require $solver_module };
	if ($@) {
		Games::CuboidPuzzle::CLI->commandUsageError(
			__x("unknown or unsupported solver '{solver}'",
				solver => $options{solver}));
	}
	my $solver = $solver_class->new;
	my @solves = $solver->solve($cube);

	foreach my $solve (@solves) {
		say join ' ', map { $cube->translateMove($_) } @$solve;
	}

	return $self;
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
