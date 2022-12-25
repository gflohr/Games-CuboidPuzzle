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
# 1x1
      i 1 2
      W 4 5
      K 7 8
X L 9 0 D E F G H I J p
Y M A 3 P Q R S T U V m
Z N B 6 b c d e f g h j
      C k l
      O n o
      a q r
# 1x2
      j 1 2
      m 4 5
      p 7 8
Z Y X i D E F G H I J a
N M L W P Q R S T U V O
B A 9 K b c d e f g h C
      0 k l
      3 n o
      6 q r
# 1x3
      C 1 2
      O 4 5
      a 7 8
B N Z j D E F G H I J 6
A M Y m P Q R S T U V 3
9 L X p b c d e f g h 0
      i k l
      W n o
      K q r
# 2x1
      0 h 2
      3 V 5
      6 J 8
9 A B C 1 E F G H I q K
L M N O 4 Q R S T U n W
X Y Z a 7 c d e f g k i
      j D l
      m P o
      p b r
# 2x2
      0 k 2
      3 n 5
      6 q 8
9 A B C h E F G H I b K
L M N O V Q R S T U P W
X Y Z a J c d e f g D i
      j 1 l
      m 4 o
      p 7 r
# 2x3
      0 D 2
      3 P 5
      6 b 8
9 A B C k E F G H I 7 K
L M N O n Q R S T U 4 W
X Y Z a q c d e f g 1 i
      j h l
      m V o
      p J r
# 3x1
      0 1 g
      3 4 U
      6 7 I
9 A B C D 2 H T f r J K
L M N O P 5 G S e o V W
X Y Z a b 8 F R d l h i
      j k E
      m n Q
      p q c
# 3x2
      0 1 l
      3 4 o
      6 7 r
9 A B C D g f e d c J K
L M N O P U T S R Q V W
X Y Z a b I H G F E h i
      j k 2
      m n 5
      p q 8
# 3x3
      0 1 E
      3 4 Q
      6 7 c
9 A B C D l d R F 8 J K
L M N O P o e S G 5 V W
X Y Z a b r f T H 2 h i
      j k g
      m n U
      p q I
# 1y1
      0 1 2
      3 4 5
      6 7 8
9 A B C D E F G H I J K
L M N O P Q R S T U V W
a b c d e f g h i X Y Z
      l o r
      k n q
      j m p
# 1y2
      0 1 2
      3 4 5
      6 7 8
9 A B C D E F G H I J K
L M N O P Q R S T U V W
d e f g h i X Y Z a b c
      r q p
      o n m
      l k j
# 1y3
      0 1 2
      3 4 5
      6 7 8
9 A B C D E F G H I J K
L M N O P Q R S T U V W
g h i X Y Z a b c d e f
      p m j
      q n k
      r o l
# 2y1
      0 1 2
      3 4 5
      6 7 8
9 A B C D E F G H I J K
O P Q R S T U V W L M N
X Y Z a b c d e f g h i
      j k l
      m n o
      p q r
# 2y2
      0 1 2
      3 4 5
      6 7 8
9 A B C D E F G H I J K
R S T U V W L M N O P Q
X Y Z a b c d e f g h i
      j k l
      m n o
      p q r
# 2y3
      0 1 2
      3 4 5
      6 7 8
9 A B C D E F G H I J K
U V W L M N O P Q R S T
X Y Z a b c d e f g h i
      j k l
      m n o
      p q r
# 3y1
      6 3 0
      7 4 1
      8 5 2
C D E F G H I J K 9 A B
L M N O P Q R S T U V W
X Y Z a b c d e f g h i
      j k l
      m n o
      p q r
# 3y2
      8 7 6
      5 4 3
      2 1 0
F G H I J K 9 A B C D E
L M N O P Q R S T U V W
X Y Z a b c d e f g h i
      j k l
      m n o
      p q r
# 3y3
      2 5 8
      1 4 7
      0 3 6
I J K 9 A B C D E F G H
L M N O P Q R S T U V W
X Y Z a b c d e f g h i
      j k l
      m n o
      p q r
# 1z1
      0 1 2
      3 4 5
      Z N B
9 A j a O C 6 G H I J K
L M k b P D 7 S T U V W
X Y l c Q E 8 e f g h i
      d R F
      m n o
      p q r
# 1z2
      0 1 2
      3 4 5
      l k j
9 A d c b a Z G H I J K
L M R Q P O N S T U V W
X Y F E D C B e f g h i
      8 7 6
      m n o
      p q r
# 1z3
      0 1 2
      3 4 5
      F R d
9 A 8 E Q c l G H I J K
L M 7 D P b k S T U V W
X Y 6 C O a j e f g h i
      B N Z
      m n o
      p q r
# 2z1
      0 1 2
      Y M A
      6 7 8
9 m B C D E F 3 H I J K
L n N O P Q R 4 T U V W
X o Z a b c d 5 f g h i
      j k l
      e S G
      p q r
# 2z2
      0 1 2
      o n m
      6 7 8
9 e B C D E F Y H I J K
L S N O P Q R M T U V W
X G Z a b c d A f g h i
      j k l
      5 4 3
      p q r
# 2z3
      0 1 2
      G S e
      6 7 8
9 5 B C D E F o H I J K
L 4 N O P Q R n T U V W
X 3 Z a b c d m f g h i
      j k l
      A M Y
      p q r
# 3z1
      X L 9
      3 4 5
      6 7 8
p A B C D E F G 0 K W i
q M N O P Q R S 1 J V h
r Y Z a b c d e 2 I U g
      j k l
      m n o
      f T H
# 3z2
      r q p
      3 4 5
      6 7 8
f A B C D E F G X i h g
T M N O P Q R S L W V U
H Y Z a b c d e 9 K J I
      j k l
      m n o
      2 1 0
# 3z3
      H T f
      3 4 5
      6 7 8
2 A B C D E F G r g U I
1 M N O P Q R S q h V J
0 Y Z a b c d e p i W K
      j k l
      m n o
      9 L X
