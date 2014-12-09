<!-- vim: set ft=markdown fo+=aw : Hurray for working on a Vim project -->
# Vim-Legend

This plugin sets up the sign column from coverage files to indicate which lines
have been hit/missed/ignored, similar to the HTML output of coverage reporters
like [simplecov](https://github.com/colszowka/simplecov) for Ruby.
Following naturally, this plugin needs Vim to be compiled with the `+signs` 
feature.

Currently, vim-legend only parses the output of a Ruby gem called
[cadre](https://github.com/nyarly/cadre/), but the intention is to expand to
different coverage systems and multiple languages.

Once installed, it will try to detect respective coverage files whenever you
enter a buffer. A quick glance at the sign colum will help you see what's been
tested and what's not.
Optionally, you are be able to highlight line background as well.

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

## Why "legend"?

In spy jargon, a "legend" is the cover story constructed by and agency for its
operatives.
A legend is also that list on a map that explains all the symbols.
