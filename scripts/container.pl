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
use JSON;
use IO::All;
use File::Spec::Functions;
use Data::Dumper;
use List::MoreUtils;
use Carp;
use utf8;

use constant ENV_FILE => catfile( $ENV{HOME}, 'Documents/environments.txt' );
use constant TYPES => map { ref $_ } ( {}, [], qr//, \'' );

my $JSON = JSON->new->allow_nonref;
my $ENVS;

my $verbose;

# get all envs. TODO: take direct from bazaar, instead of file 
sub init_env {
    $ENVS = $JSON->decode( scalar io->file(ENV_FILE)->slurp );
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

sub connect_with {
    my $cont_name = shift;
    my @conts = get_container_by_name( $cont_name );

    croak "Container named $cont_name Not found" unless @conts;
    my $cont = shift @conts; # get first .TODO: if more than one ?

    my $ip   = $cont->{rh_ip};
    my $port = '10003'; # which port ? TODO: how to know the port?

    my $cmd = "ssh -p $port root\@$ip";
}

# entry point
sub main {
    init_env;

    #say Dumper($ENVS);
    #say Dumper( parse_env );
    #say Dumper( get_container_by_name qr/kanboard/);
    #say Dumper( get_env_by_name qr/kanboard/ );
    #say Dumper( get_all_envs );
    #say Dumper(get_all_containers);
    say connect_with qr/kanboard/;
    
    

    # print all modules loaded
    say join("\n", map { s|/|::|g; s|\.pm$||; $_ } keys %INC) if $verbose;
}

main();
