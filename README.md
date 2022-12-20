# Games-CuboidPuzzle

This library implements a Perl Representation of cuboid puzzles in arbitrary
sizes.  The most famous cuboid puzzle is the 3x3 Rubik's cube.

See [Games::CuboidPuzzle](https://github.com/gflohr/Games-CuboidPuzzle/blob/master/lib/Games/CuboidPuzzle.pod)
for more information.

- [Games-CuboidPuzzle](#games-cuboidpuzzle)
	- [Status](#status)
	- [Installation](#installation)
	- [Copyright](#copyright)

## Status

Work in progress.

## Installation

Via CPAN:

```shell
$ perl -MCPAN -e install 'Games::CuboidPuzzle'
```

From source:

```shell
$ perl Build.PL
Created MYMETA.yml and MYMETA.json
Creating new 'Build' script for 'Games-CuboidPuzzle' version '0.1'
$ ./Build
$ ./Build install
```

From source with "make":

```shell
$ git clone https://github.com/gflohr/Games-CuboidPuzzle.git
$ cd Games-CuboidPuzzle
$ perl Makefile.PL
$ make
$ make install
```

## Copyright

Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>.