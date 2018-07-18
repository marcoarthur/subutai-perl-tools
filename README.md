# NAME

Bazaar - Manages Subutai containers on a perl environment

# SYNOPSIS

    use Bazaar;

    my $c = Bazaar->new( username => 'my@user.com', password => 'topsecret' );
    my $containers = $c->peer('my-peer')->env('my-env')->containers

# DESCRIPTION

Bazaar a rest client that helps in manage containers from a perl environment. 

# AUTHOR

Marco Arthur <arthurpbs@gmail.com>

# COPYRIGHT

Copyright 2018- Marco Arthur

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

