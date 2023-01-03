#! /bin/false

# Copyright (C) 2022 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What the Fuck You Want
# to Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

package Games::CuboidPuzzle::Command;

use strict;

use File::Spec;
use Getopt::Long 2.36 qw(GetOptionsFromArray);

use Games::CuboidPuzzle::CLI;

sub new {
	my ($class) = @_;

	my $self = '';
	bless \$self, $class;
}

sub run {
	my ($self, $args, $global_options) = @_;

	$args ||= [];
	my %options = $self->parseOptions($args);

	return $self->_run($args, $global_options, %options);
}

sub parseOptions {
	my ($self, $args) = @_;

	my %options = $self->_getDefaults;
	my %specs = $self->_getOptionSpecs;
	$specs{help} = 'h|help';

	my %optspec;
	foreach my $key (keys %specs) {
		$optspec{$specs{$key}} =
				ref $options{$key} ? $options{$key} : \$options{$key};
	}

	Getopt::Long::Configure('bundling');
	{
		local $SIG{__WARN__} = sub {
			$SIG{__WARN__} = 'DEFAULT';
			$self->__usageError(shift);
		};

		GetOptionsFromArray($args, %optspec);
	}

	# Exits.
	$self->_displayHelp if $options{help};

	return %options;
}

sub _getDefaults {}
sub _getOptionSpecs {};

sub __usageError {
	my ($self, @msg) = @_;

	my $class = ref $self;
	$class =~ s/^Games::CuboidPuzzle::Command:://;
	my $cmd = join '-', map { lcfirst $_ } split /::/, $class;

	return Games::CuboidPuzzle::CLI->commandUsageError($cmd, @msg);
}

sub _displayHelp {
	my ($self) = @_;

	my $class2module = sub {
		my ($class) = @_;

		$class =~ s{(?:::|')}{/}g;

		return $class . '.pm';
	};

	my $module = class2module->(ref $self);

	my $path = $INC{$module};
	$path = './' . $path if !File::Spec->file_name_is_absolute($path);

	$^W = 1 if $ENV{'PERLDOCDEBUG'};
	pop @INC if $INC[-1] eq '.';
	require Pod::Perldoc;
	local @ARGV = ($path);
	exit(Pod::Perldoc->run());
}

1;
