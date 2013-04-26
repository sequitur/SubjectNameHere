package Buzzwords::Reader;

use strict;
use warnings;
use v5.16;

use Exporter 'import';

# Reads a buzzword file and returns a hash with its contents.

sub get_buzzwords {
    my ($bzpath) = @_;

    open(BUZZWORDS, '<', $bzpath) or die "Can't open buzzword file: $!";

    my $current_block_name = 'default';
    my @current_block_content;

    my %buzzwords;

    while (<BUZZWORDS>) {

        chomp;
        s/^\s*(\S*)#.*/$1\n/; # Strip out comments and leading whitespace.
        next if /^$/; # Empty line; do nothing.

        if ( /^\[(.+)\]/ ) { # Start of a new block

            %buzzwords = ( %buzzwords,
                $current_block_name => [ @current_block_content ] );

            $current_block_name = $1;
            @current_block_content = ();
            next
        }

        # If this is neither an empty line nor a block header, assume it's
        # a line containing block content.

        push( @current_block_content, split( qr/\|/, $_ ) );
    }

    %buzzwords = ( %buzzwords,
        $current_block_name => [ @current_block_content] );

    close BUZZWORDS;

    return %buzzwords
}

our @EXPORT = qw( get_buzzwords );
