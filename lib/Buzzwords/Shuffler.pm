package Buzzwords::Shuffler;

use Mouse;
use namespace::autoclean;

use v5.16;
use List::Util 'shuffle';
use Lingua::EN::Inflect 'A';

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
        my $func_name = $category;

        __PACKAGE__->meta->add_method(
            "_shuffle_$func_name" => 
            $self->_make_iterator(${$self->buzzwords}{$category})
        );

    }

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

sub _make_iterator {
    my ($self, $arg) = @_;
    my @shuffled = shuffle @$arg;
    
    return sub {
        my ($self, %opts) = @_;
        state $static;

        if ($opts{static}) {
            return $static if $static;

            $static = pop @shuffled;
            return $static;
        }

        my $phrase = pop @shuffled;

        return $phrase;
    };
};


sub _generator {
    my $self = shift;
    my @args = split(' ', shift);
    my $inflect = 0;

    if ($args[0] =~ /^(a|an)$/) {
        shift @args;
        $inflect = 1;
    }

    my ($category, $option) = @args;

    my $func_name = "_shuffle_$category";

    my $phrase = '';

    if ($option) {
        if ($option eq 'static') {
            $phrase = $self->$func_name( static => 'yes' ) }
        if ($option =~ /\d+:\d+/ ) {
            my ($lower, $upper) = split(':', $option);
            my $range = $upper - $lower;
            my $number = ( int( rand( $range ) ) )+ $lower;

            foreach (0..$number) {
                $phrase .= $self->$func_name();
            }
        }
    }
    else { $phrase = $self->$func_name() }

    while ($phrase =~ /\<([a-z0-9_: ]+)\>/) {
        my $local1 = $1; # Global variables are the devil.
        my $replacement = $self->_generator($local1);
        $phrase =~ s/<$local1>/$replacement/;
    }

    return A($phrase) if $inflect;
    return $phrase;
}


sub content {
    my $self = shift;
    return $self->_generator('main');
}

__PACKAGE__->meta->make_immutable();

1;
