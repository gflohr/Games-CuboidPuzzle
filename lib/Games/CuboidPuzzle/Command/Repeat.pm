#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Command::Repeat;

use strict;

use Games::CuboidPuzzle;

use base qw(Games::CuboidPuzzle::Command);

use Locale::TextDomain 'Games-CuboidPuzzle';

sub _getDefaults { count => 1 }

sub _getOptionSpecs {
	count => 'c|count:i',
	verbose => 'v|verbose',
}

sub _run {
	my ($self, $args, $global_options, %options) = @_;

	if ($options{count} <= 0) {
		Games::CuboidPuzzle::CLI->commandUsageError(repeat
			=> __"count must be a positive integer");
	}

	if (!$options{verbose} && $options{count} != 1) {
		Games::CuboidPuzzle::CLI->commandUsageError(repeat
			=> __"--count only makes sense with --verbose");
	}

	if (!@$args) {
		Games::CuboidPuzzle::CLI->commandUsageError(repeat
			=> __"repeatedly doing nothing does not make a lot of sense");
	}

	my $cube = $self->_cube($global_options);
	my @moves = $self->_expandMoves($args);
	my $count = 0;
	while (1) {
		++$count;
		foreach my $move (@moves) {
			$cube->move($move);
		}
		last if $cube->conditionSolved;
		if ($options{verbose} && !($count % $options{count})) {
			print STDERR __nx("one repetition\n", "{count} repetitions\n",
				$count, count => $count);
		}
	}

	print "$count\n";
}

1;

=head1 NAME

cuboid repeat - Repeat an algorithm until the initial state is reached again

=head1 SYNOPSIS

    cuboid repeat [<global options>] [--verbose] MOVES...

=head1 DESCRIPTION

The command applies B<MOVES> to the specified cube until the cube is in
solved state.  It prints the number of iterations required on standard output.

Each move argument is automatically split at spaces and tabs.  As a convenience,
you may replace the single quote character "'" with the lowercase letter i.

=head1 OPTIONS

=over 4

=item -v, --verbose[=COUNT]

Reports the number of repetitions executed on standard error.  If B<COUNT>
was given, groups of B<COUNT> repetitions are reported.

=item -h, --help

Show this help page and exit.

=back

=head1 SEE ALSO

cuboid(1), perl(1)
