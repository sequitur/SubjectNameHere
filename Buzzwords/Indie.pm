package Buzzwords::Indie;

use Mouse;
use namespace::autoclean;

use v5.16;
use Lingua::EN::Inflect qw( A AN );
use List::Util 'shuffle';

# Generates random buzzword-laden pitches for indie games.

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




sub gen_game_name {
    my $self = shift;
    my @generators = shuffle (

        sub {
            return $self->gen_name_openers . ' '
            . $self->gen_name_nouns_plural;
        }
    );

    return $generators[rand @generators]->();

}

# Takes a list of items, and returns a reference to an anonymous stateful 
# function that iterates returns those items one at a time in a random order.

sub make_iterator {
    my $self = shift;

    my $i = 0;
    my @buzzwords = shuffle(@{$_[0]});

    return sub {
        return $buzzwords[$i++];
    };
}

# Same as make_iterator, but returns foo/bar 25% of the time.

sub make_adjectivator {
    # Yeah, yeah, special cases, whatever
    my $i = 0;
    my @buzzwords = @{$_[0]};

    return sub {
        return $buzzwords[$i++] .
            ((rand > 0.75)?'':('/' . $buzzwords[$i++]));
    };
}

#### Primitive Generators ####
# We turn our hash of keys => array references which hold our source word lists,
# and make it into a hash of keys => function references which point to closures
# that themselves iterate over a randomized list of buzzwords.


#### Composite Generators ####
# Those functions take the primitives we defined before and mash them together
# into sentences and sentence fragments. A common pattern here is to pick random
# functions out of a list of anonymous functions to choose what kind of
# phrase to insert.

sub gen_game_genre {
    # Returns a string for the game's genre, which has a chance of including
    # two adjectives.
    #
    my $self = shift;

    return 
        $self->gen_adj 
        . ((rand > 0.7)?(', ' . $self->gen_adj):'')
        . ' ' .  $self->gen_category;
}

sub gen_with {

    # Variations on a theme.

    my $self = shift;

    my @with_subs = (
        sub {
            return ' with ' . $self->gen_adj . ' ' . $self->gen_category
                . ' elements.';
        },

        sub {
            return ' that pays homage to classic ' . $self->gen_adj
                . ' ' . $self->gen_category . ' games.';
        },

        sub {
            return ' based around manipulating ' . $self->gen_gameplay 
                . ' to solve puzzles.';
        },

        sub {
            return ' that is more ' . A($self->gen_adj)
            . ' experiment than a \'game.\'';
        }

    );

    return $with_subs[rand @with_subs]->();
}

sub gen_gimmick {

    my $self = shift;
    my @gimmick_subs = (
        sub {
            return 'The ' . $self->gen_adj . ' gameplay consists of using ' . $self->gen_input
                . ' to control ' . $self->gen_gameplay . ', in order to ' . $self->gen_goals
                . '.';
            },

        sub {
            return 'The game explores issues of '
            . ' ' . $self->gen_issues . ', ' . $self->gen_issues . ', and ' . $self->gen_issues
            . ' in the context of ' . $self->gen_adj . ' gameplay.'
        }

    );

    return $gimmick_subs[rand @gimmick_subs]->();
}



sub gen_character {

    my $self = shift;
    return $self->gen_character_names . ', ' . A($self->gen_character_archetype());
}

sub gen_character_archetype {

    my $self = shift;
    return $self->gen_character_adj . ' ' . $self->gen_character_type;
}

sub gen_task {

    my $self = shift;
    my @task_subs = (
        sub {
            return ' tasked with defeating ' . A($self->gen_character_archetype()) . '.';
        },

        sub {
            return ', who must rescue ' . A($self->gen_character_archetype()) 
                . ' from certain death.'
        },

        sub {
            return ', and use only  your ' . $self->gen_tool
                . ' to navigate the maze-like environment of '
                . A($self->gen_environment_adj) . ' ' . $self->gen_environment . '.';
        }
    );

    return $task_subs[rand @task_subs]->();
}

sub gen_protagonist {

    my $self = shift;
    return 'You play as ' . $self->gen_character() . $self->gen_task();
}


sub gen_game_intro {

    my $self = shift;
    return $self->gen_game_name() . ' is ' . A($self->gen_game_genre() 
        . $self->gen_with())
        . ' ' . $self->gen_gimmick();
}

sub gen_features {

    my $self = shift;
    # First, we set up a list subroutines that return features.

    my @feature_subs = (
        sub {
            return '- Over ' . int( rand(256) ). ' '
                . $self->gen_environment_adj . ' levels!'
        },

        sub {
            return '- Play as ' . A($self->gen_character_type) 
                . ', ' . A($self->gen_character_type) . ' or '
                . A($self->gen_character_type)
                . '!';
        },

        sub {
            return '- Free to Play with ' 
                . $self->gen_microtransaction_adj
                . ' microtransactions!';
        },

        sub {
            return '- ' . int( rand(256) ) . ' achievements to unlock!';
        },

        undef # We use the null value as a delimiter...
    );

    my @features;

    foreach my $sub (shuffle(@feature_subs)) {
        # If we reach the null value, stop iterating.
        # Thus, our list of features has a random number of features.
        last unless $sub;
        push @features, ($sub->() . "\n");
    }
    return @features;
}

sub generate_content {

    my $self = shift;

    return $self->gen_game_intro . "\n\n"
        . $self->gen_protagonist . "\n\n"
        . join('', $self->gen_features());
}

__PACKAGE__->meta->make_immutable();

1;
