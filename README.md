# SubjectNameHere

A random generator for buzzword-laden indie gaming pitches, written in Perl.

## Data Format

Subject Name Here takes random words and phrases from a plain text file called
'indiegaming.buzz'. That file defines the whole structure of the generated 
text.

The format for buzzword files is:

- Everything after a `//` is treated as a comment and ignored.
- The file is split into blocks, headed by `[headers]`. Everything before the 
  top header is treated as part of the `[default]` block.
- Normal blocks contain lists of words or snippets of text separated by pipes 
  `|` and newlines.
- Blocks whose names start with `phrase_`, on the other hand, contain phrases 
  separated by lines that contain only a `%`.
- Either way, phrases can contain `<references>` to other blocks. References 
  get replaced with one of the phrases in the corresponding block, chosen at 
  random. The format for a reference is `<[a] reference [option]>`.
  + `[a]`, which can actually be written `a` or `an`, will use 
    Lingua::EN::Inflect to put an 'a' or 'an' before the content of the 
    reference, as dictated by English grammar.
  + `[option]` can be one of two things:
        * `static` will make the block static. This means the block will pick 
          one option at random, and then that option will be chosen again every 
          time the block is called subsequently with the `static` option. Keep 
          in mind that if the block contains references to other blocks, those 
          references will change unless they, too, are called statically.
        * `x:y`, where x and y are numbers, will call the block repeatedly at least 
        x times and at most y times.

Reading the actual file will probably make this much more clearer. The `[main]` block is 
the only one explicitly called by the Shuffler module; `[main]` in turn calls 
other blocks.
