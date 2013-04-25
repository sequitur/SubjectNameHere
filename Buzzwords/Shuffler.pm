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

    foreach my $category (keys %{$self->buzzwords}) {
        my $func_name = $category;
        $func_name =~ s/:/_/g;

        __PACKAGE__->meta->add_method(
            "gen_$func_name" => $self->make_iterator(${$self->buzzwords}{$category})
        );

    }
}

has buzzwords => (
    is => 'ro',
    isa => 'HashRef',
    default => sub {
        use Buzzwords::Reader;
        my %buzzwords = get_buzzwords('indiegaming.buzz');
        return \%buzzwords;
    },
);

sub make_iterator {
    my $self = shift;

    my $i = 0;
    my @buzzwords = shuffle(@{$_[0]});

    return sub {
        return $buzzwords[$i++];
    };
}

__PACKAGE__->meta->make_immutable();

1;
