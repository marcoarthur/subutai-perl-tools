#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: container.pl
#
#        USAGE: container.pl [name]
#
#  DESCRIPTION: Script to get container info and manage connections with
#               containers.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Marco Arthur (itaipu), arthurpbs@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 07/16/2018 10:46:01 PM
#     REVISION: ---
#===============================================================================

use 5.010;
use strict;
use warnings;
use JSON;
use IO::All;
use File::Spec::Functions;
use List::MoreUtils;
use Carp;
use Getopt::Long;
use Pod::Usage;

#use List::Util qw( tail );
use utf8;

my $ENV_FILE = catfile( $ENV{HOME}, 'Documents/environments.txt' );
use constant TYPES => map { ref $_ } ( {}, [], qr//, \'' );

my $JSON = JSON->new->allow_nonref;
my $ENVS;

my $verbose;

# init all envs. TODO: take direct from bazaar, instead of file 
sub init_env {
    $ENVS = $JSON->decode( scalar io->file($ENV_FILE)->slurp );
}

# does parsing to remove prefix
sub parse_env {
    my $key = qr/(?<prefix>\w+)_(?<sufix>\w+)/;
    my @envs;

    # Drop prefix of hash
    foreach my $hash ( @$ENVS ) {
        my %env = map { /$key/; $+{sufix} => $hash->{$_} } keys %$hash;
        push @envs, \%env;
    }

    wantarray ? @envs : \@envs;
}

# check for a valid reference
sub check_ref {
    my $ref   = shift; # mandatory
    my $type  = shift; # optional
    
    return any { $_  eq $ref } TYPES unless $type;
    return ref $ref eq $type;
}

# get environment(s) data using its name pattern
sub get_env_by_name {
    my $pattern = shift;
    croak "Want regexp" unless check_ref( $pattern, 'Regexp' );

    my @envs = parse_env;
    @envs = grep { $_->{name} =~ /$pattern/ } @envs;

    wantarray ? @envs : \@envs;
}

# get container(s) data using its name pattern
sub get_container_by_name {
    my $pattern = shift;
    croak "Want regexp" unless check_ref( $pattern, 'Regexp' );

    my @envs = parse_env;
    my @containers = map { @{ $_->{containers} } } @envs;
    @containers = grep { $_->{container_name} =~ /$pattern/ } @containers;

    wantarray ? @containers : \@containers;
}

# list all environments
sub get_all_envs {
    return get_env_by_name qr/.*/ ;
}

# list all containers
sub get_all_containers {
    return get_container_by_name qr/.*/ ;
}

# connect info for container
sub connect_with {
    my $cont_name = shift;
    my @conts = get_container_by_name( $cont_name );

    croak "Container named $cont_name Not found" unless @conts;

    my $solve_ip_port = sub { 
        my $cont = shift;

        my $ip   = $cont->{rh_ip};

        # Container port number is taken as this: ``port number is , actually
        # computed within tray. so port = 10000+{last_number_of_ip} . from your
        # example 172.21.101.3, you take 3 and add 10000 to it, so you will get
        # 10003 as your port '' ( by Kadyr)

        my (undef, undef, undef, $last) = split /\./ , $cont->{container_ip};
        my $port = 10000 + $last;
        return ( $ip, $port );
    };


    # possible containers
    my @containers = map { [ $_->{container_name}, &$solve_ip_port( $_ ) ] } @conts;
}

# construct external command
sub show_cmd {
    my $tuple = shift;

    my ($name, $ip, $port) = @$tuple;

    my $ssh_tmpl = 'ssh -p %d root@%s # %s';

    say sprintf $ssh_tmpl, $port, $ip, $name;
    
}

# entry point
sub main {
    my ($help, $man) = ( 0, 0 );

    GetOptions(
        "verbose" => \$verbose,
        "env_file=s" => \$ENV_FILE,
        "help|?" => \$help,
        "man" => \$man,
    ) or pod2usage(2);

    pod2usage(0) if $help;
    pod2usage(-exitval => 0, -verbose => 2) if $man;

    init_env;
    my $cont_name = shift @ARGV or pod2usage(1);

    foreach my $cont ( connect_with qr/$cont_name/ ) {
        show_cmd $cont;
    }
}

main();

__END__

=head1 container.pl

 container.pl - output command info to connect to a Subutai container.

=head1 SYNOPSIS

 containerl.pl [options] container_name

 Options:
    - help | man        display this help
    - env_file          use environment json info file, default ( ~/Documents/environments.txt )
    - verbose           run with debug info

=head1 Description

 This program is licensed under GPL.
