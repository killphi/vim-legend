<!-- vim: set ft=markdown fo+=aw : Hurray for working on a Vim project -->
# Vim-Legend

This plugin parses coverage files and creates signs in the left gutter to
indicate which lines have been hit/missed/ignored.

Currently, vim-legend parses the output of a Ruby gem called
[cadre](https://github.com/nyarly/cadre/), but the
intention is to expand the possible coverage files to different coverage
systems and languages.

Once it's installed, it will detect coverage files whenever you enter a buffer.
You'll see signs on the left of the file indicating what's been tested and
what's not. Most of the time, they're easy to ignore and when you need to know
what code has been covered and what's not, it's super handy.

## Oh, a screenshot:

Vim with Legend  | Simplecov HTML output
-----------------|-----------------------
<img src="https://raw.githubusercontent.com/killphi/vim-legend/master/vim.png" style="float: left"> | <img src="https://raw.githubusercontent.com/killphi/vim-legend/master/simplecov.png" style="float: left">

# Installation

You should be able to use your preferred Vim package manager. I for one like Vundle:

Add this to your .vimrc:
```
Bundle 'killphi/vim-legend'
```

And then:
```
:Bundle
```

## Why "legend" ?

In spy jargon, a "legend" is the cover story constructed by and agency for its
operatives. So it's a kind of a play on words, you see. A legend is also the
list of symbols on a map to describe what they mean. So, it's a tool to guide
and protect you while you code.

## Adapters

The actual format vim-legend uses is just a Vim script, and pretty simple at that.
It's possible to write programs to convert the output of other coverage tools
into the vim-legend format.
In fact, there's already a program to do this for Go:
https://github.com/nyarly/legendary
