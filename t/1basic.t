#!/usr/bin/perl
use Test::More qw(no_plan);
use strict;
BEGIN {
use_ok 'Data::Hierarchy';
}

my $tree = Data::Hierarchy->new();
$tree->store ('/', {access => 'all'});
$tree->store ('/private', {access => 'auth', type => 'pam'});
$tree->store ('/private/fnord', {otherinfo => 'fnord'});
$tree->store ('/blahblah', {access => {fnord => 'bzz'}});

ok (eq_hash (scalar $tree->get ('/private/somewhere/deep'), {access => 'auth',
							     type => 'pam'}));

ok (eq_hash (scalar $tree->get ('/private'), {access => 'auth',
					      type => 'pam'}));

ok (eq_hash (scalar $tree->get ('/private/fnord/blah'), {access => 'auth',
							 otherinfo => 'fnord',
							 type => 'pam'}));

ok (eq_hash (scalar $tree->get ('/private/fnordofu'), {access => 'auth',
						       type => 'pam'}));

is (($tree->get ('/private/somewhere/deep'))[-1], '/private');
is (($tree->get ('/public'))[-1], '');

ok (eq_array ([$tree->find ('/', {access => qr/.*/})],
	      ['','/blahblah','/private']));

$tree->store ('/private', {type => undef});

ok (eq_hash (scalar $tree->get ('/private'), { access => 'auth' }));

$tree->store_recursively ('/', {access => 'all', type => 'null'});

is_deeply ([$tree->get ('/private/fnord/somewhere/deep')],
	   [{access => 'all',
	     otherinfo => 'fnord',
	     type => 'null', }, '','/private/fnord']);