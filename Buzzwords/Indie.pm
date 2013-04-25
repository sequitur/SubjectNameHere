package Buzzwords::Indie;

use strict;
use warnings;
use v5.16;

use Exporter 'import';

# Lingua::EN::Inflect helps us with correctly and consistently placing the
# a/an article in front of nouns.

use Lingua::EN::Inflect qw( A AN );

# List::Util gives us the shuffle() function which we're going to be making
# heavy use of.

use List::Util 'shuffle';

use Buzzwords::Reader;

# Generates random buzzword-laden pitches for indie games.

my %buzzwords = get_buzzwords('indiegaming.buzz');

sub gen_game_name {
    my @generators = shuffle (

        sub {
            my ($opener) = shuffle(@{$buzzwords{'name:openers'}});
            my ($noun) = shuffle(@{$buzzwords{'name:nouns:plural'}});
            return $opener . ' ' . $noun;
        }
    );

    return $generators[rand @generators]->();

}

# Takes a list of items, and returns a reference to an anonymous stateful 
# function that iterates returns those items one at a time in a random order.

sub make_iterator {
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

my %generators;
foreach my $category (keys %buzzwords) {
    %generators = ( %generators,
        $category => make_iterator($buzzwords{$category}) );
};

sub gen {
    # This sub is basically sugar. It takes the name of a
    # word generator stored in %generators and calls it, returning
    # its value.
    
    my ($category) = @_;

    if (not $generators{$category}) { die "Can't find generator $category!" };

    return $generators{$category}->();
}

#### Composite Generators ####
# Those functions take the primitives we defined before and mash them together
# into sentences and sentence fragments. A common pattern here is to pick random
# functions out of a list of anonymous functions to choose what kind of
# phrase to insert.

sub gen_game_genre {
    # Returns a string for the game's genre, which has a chance of including
    # two adjectives.
    #
    return 
        gen('adj') 
        . ((rand > 0.7)?(', ' . gen('adj')):'')
        . ' ' .  gen('category');
}

sub gen_with {

    # Variations on a theme.

    my @with_subs = (
        sub {
            return ' with ' . gen('adj') . ' ' . gen('category')
                . ' elements.';
        },

        sub {
            return ' that pays homage to classic ' . gen('adj')
                . ' ' . gen('category') . ' games.';
        },

        sub {
            return ' based around manipulating ' . gen('gameplay') 
                . ' to solve puzzles.';
        },

        sub {
            return ' that is more ' . A(gen('adj'))
            . ' experiment than a \'game.\'';
        }

    );

    return $with_subs[rand @with_subs]->();
}

sub gen_gimmick {
    my @gimmick_subs = (
        sub {
            return 'The ' . gen('adj') . ' gameplay consists of using ' . gen('input')
                . ' to control ' . gen('gameplay') . ', in order to ' . gen('goals')
                . '.';
            },

        sub {
            return 'The game explores issues of '
            . ' ' . gen('issues') . ', ' . gen('issues') . ', and ' . gen('issues')
            . ' in the context of ' . gen('adj') . ' gameplay.'
        }

    );

    return $gimmick_subs[rand @gimmick_subs]->();
}



sub gen_character {
    return gen('character:names') . ', ' . A(gen_character_archetype());
}

sub gen_character_archetype {
    return gen('character:adj') . ' ' . gen('character');
}

sub gen_task {
    my @task_subs = (
        sub {
            return ' tasked with defeating ' . A(gen_character_archetype()) . '.';
        },

        sub {
            return ', who must rescue ' . A(gen_character_archetype()) 
                . ' from certain death.'
        },

        sub {
            return ', and use only  your ' . gen('tool')
                . ' to navigate the maze-like environment of '
                . A(gen('environment:adj')) . ' ' . gen('environment') . '.';
        }
    );

    return $task_subs[rand @task_subs]->();
}

sub gen_protagonist {
    return 'You play as ' . gen_character() . gen_task();
}


sub gen_game_intro {
    return gen_game_name() . ' is ' . A(gen_game_genre() . gen_with())
        . ' ' . gen_gimmick();
}

sub gen_features {
    # First, we set up a list subroutines that return features.

    my @feature_subs = (
        sub {
            return '- Over ' . int( rand(256) ). ' '
                . gen('environment:adj') . ' levels!'
        },

        sub {
            return '- Play as ' . A(gen('character')) 
                . ', ' . A(gen('character')) . ' or '
                . A(gen('character'))
                . '!';
        },

        sub {
            return '- Free to Play with ' 
                . gen('microtransaction:adj')
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
    return gen_game_intro . "\n\n"
        . gen_protagonist . "\n\n"
        . join('', gen_features());
}

our @EXPORT = qw( generate_content );
