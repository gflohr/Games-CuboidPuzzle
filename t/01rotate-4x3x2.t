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
# x2
    i j k l
    m n o p
X W h g f e d c b a Z Y
L K V U T S R Q P O N M
9 8 J I H G F E D C B A
    0 1 2 3
    4 5 6 7
# z2
    7 6 5 4
    3 2 1 0
E F G H I J 8 9 A B C D
Q R S T U V K L M N O P
c d e f g h W X Y Z a b
    p o n m
    l k j i
# y2
    p o n m
    l k j i
d c b a Z Y X W h g f e
R Q P O N M L K V U T S
F E D C B A 9 8 J I H G
    7 6 5 4
    3 2 1 0
