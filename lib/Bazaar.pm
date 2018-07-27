package Bazaar;

use Moose;
use Carp;
use Mojo::UserAgent;

has username => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has password => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has ua => (
    is => 'ro',
    isa => 'Mojo::UserAgent',
    builder => '_build_ua',
    lazy => 1,
);

# builds useragent to be used on bazaar transactions
sub _build_ua {
    my $ua = Mojo::UserAgent->new;
    $ua->max_redirect(5);
    ...
}

# builds object representing bazaar services
sub BUILD {
    ...
}

# Authenticate on bazaar. Login at Bazaar.
sub auth {
    ...
}


1;
