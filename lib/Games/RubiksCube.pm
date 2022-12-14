#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::RubiksCube;

use strict;
use v5.10;

my %defaults = {
	xwidth => 3,
	ywidth => 3,
	zwidth => 3,
	colors => [qw(G O W R Y B)],
};

sub new {
	my ($class, %args) = @_;

	my $self = {};
	foreach my $key (keys %defaults) {
		$self->{"__$key"} = $args{$key} // $defaults{$key};
	}

	bless $self, $class;
}

sub xwidth { shift->{__xwidth} }

sub ywidth { shift->{__ywidth} }

sub zwidth { shift->{__zwidth} }

sub colors { shift->{__colors} }

1;
