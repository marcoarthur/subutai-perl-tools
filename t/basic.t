use strict;
use Test::More;
use Bazaar::Container;
use Bazaar;
use Carp::Always;

# replace with the actual test
my $c = Bazaar->new(
    username => 'arthurpbs@gmail.com',
    password => 'pantano'
);

ok $c->auth;
ok $c->has_peers;

# peers of user
my @peers = $c->peers;

# environment in those peers
my @envs = map { $_->environments } @peers;

# containers in those environments
my @containers = map { $_->containers } @envs;

ok 1;

done_testing;
