use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Buzzwords::SubjectNameHere',
    VERSION_FROM    => 'mojosjn',
    EXE_FILES       => ['mojosjn'],
    PREREQ_PM       => {
        'Mojolicious'           => '3.96',
        'Text::Markdown'        => '1.000031',
        'Lingua::EN::Inflect'   => '1.895',
        'Mouse'                 => '1.06' },
    AUTHOR          => 'Bruno Dias <email@ommited.net>'
)
    
