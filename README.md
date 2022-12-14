# Games-RubiksCube

This library implements a Perl Representation of the Rubik's Cube Puzzle in
arbitrary sizes.

See [Games::RubiksCube](https://github.com/gflohr/Games-RubiksCube/blob/master/lib/Games/RubiksCube.pod)
for more information.

- [Games-RubiksCube](#games-rubikscube)
	- [Status](#status)
	- [Installation](#installation)
	- [Copyright](#copyright)

## Status

Work in progress.

## Installation

Via CPAN:

```shell
$ perl -MCPAN -e install 'Games::RubiksCube'
```

From source:

```shell
$ perl Build.PL
Created MYMETA.yml and MYMETA.json
Creating new 'Build' script for 'Games-RubiksCube' version '0.1'
$ ./Build
$ ./Build install
```

From source with "make":

```shell
$ git clone https://github.com/gflohr/Games-RubiksCube.git
$ cd Games-RubiksCube
$ perl Makefile.PL
$ make
$ make install
```

## Copyright

Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>.