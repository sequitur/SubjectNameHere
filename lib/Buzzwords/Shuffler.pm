package Buzzwords::Shuffler;

use Mouse;
use namespace::autoclean;

use v5.16;
use List::Util 'shuffle';

# Takes a reference to a hash such as the ones created by Buzzwords::Reader,
# and creates an object that has gen_$foo methods to randomly access them.
#
# Keep in mind that a new shuffler instance has to be created for every page
# of generated content; Buzzwords::Shuffler guarantees that the same buzzword
# won't show up twice.

sub BUILD {

    my $self = shift;

    my %shuffled_buzzwords;

    foreach my $category (keys %{$self->buzzwords}) {
        my @shuffled = shuffle( @{${$self->buzzwords}{$category}} );
        $shuffled_buzzwords{$category} = \@shuffled;
    }

    $self->buzzwords( \%shuffled_buzzwords );

}

has buzzwords => (
    is => 'rw',
    isa => 'HashRef',
    default => sub {
        use Buzzwords::Reader;
        my %buzzwords = get_buzzwords('indiegaming.buzz');
        return \%buzzwords;
    },
);

sub _generator {
    my ($self, $arg) = @_;

    my $category = ${$self->buzzwords}{$arg};
    my $phrase = pop @$category;

    while ($phrase =~ /\<([a-z:]+)\>/) {
        my $local1 = $1; # Global variables are the devil.
        my $replacement = $self->_generator($local1);
        $phrase =~ s/<$local1>/$replacement/;
    }

    return $phrase;
}


sub content {
    my $self = shift;
    return $self->_generator('main');
}

__PACKAGE__->meta->make_immutable();

1;
