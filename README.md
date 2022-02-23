#### Demo
<p align="center"><img src="https://github.com/chris-ritsen/vim-autocorrect/blob/master/demo/demo.gif?raw=true" alt="" title="vim-autocorrect demo" width=481 height=284/></p>

#### Description

This is a vim package for an autocorrect feature built on the
`iabbrev` and `spellsuggest` commands and years worth of spelling mistakes and
typos made on qwerty keyboards.  The result is useful for writing general
prose or code, but is especially good for a stream-of-consciousness or for
transcription.

The full list of 43,000 typos is in
[abbrev.vim](opt/vim-abbrev/plugin/abbrev).  It is made up of only
lines like these:

```
teh the
````

These are then added to vim as iabbrev definitions:
```
iabbrev teh the
````

It's not a grammar checker.  There's no way to fix transposition typos on
short words like from/form, but it works well for longer or difficult words.

The problem was that it takes time to source this list and with every
abbreviation added it takes vim longer to insert one, which blocks user input.
So instead of that, abbreviations are added in batches at a delay with
`timer_start`.  About 10 seconds after loading the package, it should have
sourced everything.

#### Rules

Deleting the words in [abbrev.vim](opt/vim-abbrev/plugin/abbrev) and
starting from scratch with any set of rules is an option, but the included
list was created by making every effort to avoid unintentional corrections.

- Add accents to letters only if the correct word is unambiguous.
- Add typos only; don't use this for expanding abbreviated words
- Avoid adding short words, such as those under four characters long.  The
  typo "atht" made by typing "at that" with a mistimed spacebar should not be
  corrected into "that".
- Avoid making decisions about mixed-case acronyms.
- Don't add words that are unlikely to broadly usable, such as camel case
  variable names.
- Don't attempt to localize/localise words.
- Don't change capitalization of words.
- Don't consider foreign words as typos, if known.
- Don't correct short words with a missing letter
- Don't pluralize words that weren't already pluralized.
- No synthetic typos.
- Prioritize compatibility with writing prose over code, but attempt to make
  it work with both if possible.
- Remove any autocorrection that results in a word that was unintended.
- Remove any leading characters from the previous word due to a mistimed
  spacebar press.
- Remove any typos that end up being variable names, nouns, brands, etc., but
  only when discovered.  For example, the program 'mosquitto' should not be
  corrected to 'mosquito'.

#### Installation

This is a package of two vim plugins and should be installed to
`~/.vim/pack/vim-autocorrect`.  The
[autocorrect.vim](start/vim-abbrev-add/plugin/autocorrect.vim) plugin has
functions to interactively add abbreviations to the list. By default, the
typos and their corrections are added to
[abbrev.vim](opt/vim-abbrev/plugin/abbrev.vim), but this can be overridden by
setting the variable `g:abbrev_file`.

```
let g:abbrev_file = expand('$HOME/.vim/pack/vim-autocorrect/opt/vim-abbrev/plugin/abbrev.vim')
```


#### Usage

To source the list of abbreviations (i.e., enable autocorrect):

```
:packadd vim-abbrev
```

This will take several seconds to load.

To quickly add abbreviations to the file after making typos, map the
`AutoCorrect`
command like this:

```
nnoremap <silent> <leader>d <esc>vip:call AutoCorrect()<CR>
```

The `vip` here will select the current paragraph and pull out typos and use
the built-in `spellsuggest` feature to guess at a correction.  After pressing
`enter` or `<c-j>` to confirm the new abbreviations, they will be written to
the file and added with iabbrev.  Removal of words must be done manually.
