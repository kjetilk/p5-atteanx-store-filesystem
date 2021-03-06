package Test::Attean::Store::Filesystem::Role::CreateStore;
use strict;
use warnings;

our $AUTHORITY = 'cpan:KJETILK';
our $VERSION   = '0.001';


use Moo::Role;
use Path::Tiny;

sub create_store {
	my $self = shift;
	my %args = @_;
	my $quads = $args{quads} // [];
	my $tmpdir = Path::Tiny->tempdir;
#	my $tmpdir = path('/tmp/test/')->absolute;
	my $store = Attean->get_store('Filesystem')->new(
																	 graph_dir => $tmpdir
																	);
	my $ser = Attean->get_serializer('Turtle')->new;
	my $tmpstore = Attean->get_store('Memory')->new;
	$tmpstore->add_iter(Attean::ListIterator->new(values => $quads, item_type => 'Attean::API::Quad'));
	my $tmpmodel = Attean::QuadModel->new( store => $tmpstore );
	my $g_iter = $tmpmodel->get_graphs;
	while (my $g = $g_iter->next) {
	  my $q_iter = $tmpmodel->get_quads(undef, undef, undef, $g);
	  my @triples;
	  while (my $quad = $q_iter->next) {
		 push(@triples, $quad->as_triple);
	  }
	  my $t_iter = Attean::ListIterator->new(values => \@triples, item_type => 'Attean::API::Triple');
	  my $file = $store->uri_to_filename($g);
	  $file->parent->mkpath;
	  $ser->serialize_iter_to_io($file->openw_utf8, $t_iter)
	}
	return $store;
}

1;

=pod 

=head1 NAME

Test::Attean::Store::Filesystem::Role::CreateStore - Create a Filesystem store for tests

=head1 SYNOPSIS

Either:

  use Test::More;
  use Test::Roo;
  with 'Test::Attean::QuadStore', 'Test::Attean::Store::Filesystem::Role::CreateStore';
  run_me;
  done_testing;

or:

  package TestCreateStore {
   	use Moo;
   	with 'Test::Attean::Store::Filesystem::Role::CreateStore';
  };
  my $quads = [
  				   quad(iri('http://example.org/bar'), iri('http://example.org/c'), iri('http://example.org/foo')),
               # [...]
				  ];

  my $test = TestCreateStore->new;
  my $store = $test->create_store(quads => $quads);


=head1 DESCRIPTION


There are two ways of using this. The original idea is to use it to
test a quad that uses L<Test::Attean::QuadStore> and other roles, like
in the first example in the synopsis.

It is also possible to utilize this role like in the second example to
create a store for testing other parts of the code too. In that
example, first wrap a class around the role, then create an arrayref
of quads, which should be used to populate the store. Then,
instantiate an object of the class, and call it's C<create_store>
method with the quads. Now, you have a proper store that can be used
in tests.

=head1 AUTHOR

Kjetil Kjernsmo E<lt>kjetilk@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2018 by Kjetil Kjernsmo.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
