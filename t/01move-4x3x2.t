# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

use strict;

use Test::More;

use List::Util qw(pairs);

use Games::CuboidPuzzle;
use Games::CuboidPuzzle::Renderer::Simple;

sub setup;

my @cases = setup;

my $renderer = Games::CuboidPuzzle::Renderer::Simple->new;

my @state = (0 .. 9, 'A' .. 'Z', 'a' .. 'p');

foreach my $case (pairs @cases) {
	my ($move, $wanted) = @$case;
	$move =~ s/^# *//;
	$move =~ s/ *\n$//;
	$wanted = "\n" . $wanted;
	my $cube = Games::CuboidPuzzle->new(
		xwidth => 4,
		ywidth => 3,
		zwidth => 2,
		state => [@state],
	);
	$cube->move($move);
	my $got = "\n" . $renderer->render($cube);
	is $got, $wanted, $move;
}

done_testing;

sub setup {
	my $data = join '', <DATA>;

	my @cases = split /(#.*\n)/, $data;
	shift @cases; # The first pattern is the starting point.

	return @cases;
}

1;

__DATA__
    0 1 2 3
    4 5 6 7
8 9 A B C D E F G H I J
K L M N O P Q R S T U V
W X Y Z a b c d e f g h
    i j k l
    m n o p
# 1x2
    i 1 2 3
    m 5 6 7
X W h B C D E F G H I Y
L K V N O P Q R S T U M
9 8 J Z a b c d e f g A
    0 j k l
    4 n o p
