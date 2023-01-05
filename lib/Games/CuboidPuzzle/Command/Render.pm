#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Command::Render;

use strict;

use Games::CuboidPuzzle;

use base qw(Games::CuboidPuzzle::Command);

use Locale::TextDomain 'Games-CuboidPuzzle';

sub _getDefaults {}

sub _getOptionSpecs {
}

sub _run {
	my ($self, $args, $global_options, %options) = @_;

	my $cube = $self->_cube($global_options);
	my @moves = $self->_expandMoves($args);
	foreach my $move (@moves) {
		$cube->move($move);
	}
	print $cube->render;
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
