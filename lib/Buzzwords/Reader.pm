package Buzzwords::Reader;

use strict;
use warnings;
use v5.16;

use Exporter 'import';

# Reads a buzzword file and returns a hash with its contents.

sub get_buzzwords {
    my ($bzpath) = @_;

    open(BUZZWORDS, '<:encoding(UTF-8)', $bzpath) or die "Can't open buzzword file: $!";

    my $current_block_name = 'default';
    my @current_block_content;

    my %buzzwords;
    my $phrasal = 0;

    while (<BUZZWORDS>) {

        s|//.*$||; # Strip out comments
        chomp unless $phrasal;
        next if /^\s*$/ and !$phrasal; # Empty line; do nothing.

        if ( /^\[(phrase_.+)\]/ ) { # Start of a phrasal bloc
            %buzzwords = ( %buzzwords,
                $current_block_name => [ @current_block_content ] );

            $current_block_name = $1;
            @current_block_content = ();

            $phrasal = 1;
            next;
        }

        if ( /^\[(.+)\]/ ) { # Start of a new block

            %buzzwords = ( %buzzwords,
                $current_block_name => [ @current_block_content ] );

            $current_block_name = $1;
            @current_block_content = ();
            $phrasal = 0;
            next;
        }

        if ( /^%$/ ) { # Phrasal block delimiter
            push @current_block_content, "";
            next;
        }

        # If this is neither an empty line nor a block header, assume it's
        # a line containing block content.

        if ($phrasal) {
            my $section = pop @current_block_content;
            $section = '' unless $section;
            push( @current_block_content, ($section . $_) );
            next;
        }

            push( @current_block_content, split( qr/\|/, $_ ) );
    }

    %buzzwords = ( %buzzwords,
        $current_block_name => [ @current_block_content] );

    close BUZZWORDS;

    return %buzzwords
}

our @EXPORT = qw( get_buzzwords );
