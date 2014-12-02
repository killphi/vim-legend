<!-- vim: set ft=markdown fo+=aw : Hurray for working on a Vim project -->
# Vim-Legend

This plugin parses coverage files and creates signs in the left gutter to
indicate which lines have been hit/missed/ignored.

Currently, vim-legend parses the output of a Ruby gem called 'cadre,' but the
intention is to expand the possible coverage files to different coverage
systems and languages.

Once it's installed, it will detect coverage files whenever you enter a buffer.
You'll see signs on the left of the file indicating what's been tested and
what's not. Most of the time, they're easy to ignore and when you need to know
what code has been covered and what's not, it's super handy.

## Oh, a screenshot:

<img src="https://github.com/killphi/vim-legend/blob/master/vim.png"
style="float: left">
<img src="https://github.com/killphi/vim-legend/blob/master/simplecov.png"
style="float: left">
<span style="clear: both"></span>

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
