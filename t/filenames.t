use strict;
use warnings;
use Test::More;

use Attean;
use Path::Tiny;
use Data::Dumper;

use_ok('AtteanX::Store::Filesystem');

my $local_dir = Path::Tiny->tempdir;

my $store = AtteanX::Store::Filesystem->new(
														  graph_dir => $local_dir
														 );

isa_ok($store, 'AtteanX::Store::Filesystem');

subtest 'Simple case with empty suffix' => sub {
  my $luri = URI->new('http://localhost/foo/bar');
  is($store->uri_to_filename($luri), $local_dir->stringify . '/http/localhost/foo/bar$.ttl', 'Basic filename map');
};

subtest 'Simple case with other suffix' => sub {
  my $luri = URI->new('http://localhost/foo/bar.rdf');
  is($store->uri_to_filename($luri), $local_dir->stringify . '/http/localhost/foo/bar.rdf', 'Basic filename map');
};

done_testing;
