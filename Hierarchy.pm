package Data::Hierarchy;
$VERSION = '0.11';
use strict;

=head1 NAME

Data::Hierarchy - Handle data in a hierarchical structure

=head1 SYNOPSIS

    my $tree = Data::Hierarchy->new();
    $tree->store ('/', {access => 'all'});
    $tree->store ('/private', {access => 'auth'});

    $info = $tree->get ('/private/somewhere/deep');

    # return actual data points in scalar context
    ($info, @fromwhere) = $tree->get ('/private/somewhere/deep');

    # override all children
    $tree->store_recursively ('/', {access => 'all'});

    my $hashref = $tree->dump;

=head1 DESCRIPTION

Data::Hierarchy provides a simple interface for manipulating
inheritable data attached to a hierarchical environment (like
filesystem).

=cut

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->{sep} ||= '/';
    $self->{hash} = shift;
    return $self;
}

sub store {
    my ($self, $key, $value) = @_;

    $key =~ s/$self->{sep}$//;

    my $oldvalue = $self->{hash}{$key} if exists $self->{hash}{$key};
    $self->{hash}{$key} = {%{$oldvalue||{}}, %$value};
}

sub store_recursively {
    my ($self, $key, $value) = @_;

    $key =~ s/$self->{sep}$//;
    my @datapoints = sort grep {$key.$self->{sep} eq substr($_.$self->{sep}, 0,
							    length($key)+1)}
	 keys %{$self->{hash}};

    for (@datapoints) {
	my $hash = $self->{hash}{$_};
	delete $hash->{$_} for keys %$value;
	delete $self->{hash}{$_} unless %{$self->{hash}{$_}};
    }

    $self->store ($key, $value);
}

sub get {
    my ($self, $key) = @_;

    $key =~ s/$self->{sep}$//;
    my $value = {};
    # XXX: could build cached pointer for fast traversal
    my @datapoints = sort grep {$_.$self->{sep} eq substr($key.$self->{sep}, 0,
							  length($_)+1)}
	 keys %{$self->{hash}};

    for (@datapoints) {
	$value = {%$value, %{$self->{hash}{$_}}};
    }
    return wantarray ? ($value, @datapoints) : $value;
}

sub dump {
    my ($self) = @_;
    return $self->{hash};
}

1;

=head1 AUTHORS

Chia-liang Kao E<lt>clkao@clkao.orgE<gt>

=head1 COPYRIGHT

Copyright 2003 by Chia-liang Kao E<lt>clkao@clkao.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
