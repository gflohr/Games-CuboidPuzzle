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

my @state = (0 .. 9, 'A' .. 'Z', 'a' .. 'r');

foreach my $case (pairs @cases) {
	my ($move, $wanted) = @$case;
	$move =~ s/^# *//;
	$move =~ s/ *\n$//;
	$wanted = "\n" . $wanted;
	my $cube = Games::CuboidPuzzle->new(state => [@state]);
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
      0 1 2
      3 4 5
      6 7 8
9 A B C D E F G H I J K
L M N O P Q R S T U V W
X Y Z a b c d e f g h i
      j k l
      m n o
      p q r
# 0x1
      i h g
      W V U
      K J I
X L 9 0 1 2 H T f r q p
Y M A 3 4 5 G S e o n m
Z N B 6 7 8 F R d l k j
      C D E
      O P Q
      a b c
# 0x2
      j k l
      m n o
      p q r
Z Y X i h g f e d c b a
N M L W V U T S R Q P O
B A 9 K J I H G F E D C
      0 1 2
      3 4 5
      6 7 8
# 0x3
      C D E
      O P Q
      a b c
B N Z j k l d R F 8 7 6
A M Y m n o e S G 5 4 3
9 L X p q r f T H 2 1 0
      i h g
      W V U
      K J I
# 0y1
      6 3 0
      7 4 1
      8 5 2
C D E F G H I J K 9 A B
O P Q R S T U V W L M N
a b c d e f g h i X Y Z
      p m j
      q n k
      r o l
# 0y2
      8 7 6
      5 4 3
      2 1 0
F G H I J K 9 A B C D E
R S T U V W L M N O P Q
d e f g h i X Y Z a b c
      r q p
      o n m
      l k j
# 0y3
      2 5 8
      1 4 7
      0 3 6
I J K 9 A B C D E F G H
U V W L M N O P Q R S T
g h i X Y Z a b c d e f
      l o r
      k n q
      j m p
# 0z1
      X L 9
      Y M A
      Z N B
p m j a O C 6 3 0 K W i
q n k b P D 7 4 1 J V h
r o l c Q E 8 5 2 I U g
      d R F
      e S G
      f T H
# 0z2
      r q p
      o n m
      l k j
f e d c b a Z Y X i h g
T S R Q P O N M L W V U
H G F E D C B A 9 K J I
      8 7 6
      5 4 3
      2 1 0
# 0z3
      H T f
      G S e
      F R d
2 5 8 E Q c l o r g U I
1 4 7 D P b k n q h V J
0 3 6 C O a j m p i W K
      B N Z
      A M Y
      9 L X
