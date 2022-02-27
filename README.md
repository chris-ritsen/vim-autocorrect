## Description

This is a vim package for an autocorrect feature built on the `iabbrev` and
`spellsuggest` commands and years worth of spelling mistakes and typos made on
qwerty keyboards.  The result is useful for writing general prose or code, but
is especially good for a stream-of-consciousness or for transcription.

The full list of over 44,000 typos is in
[abbrev](opt/vim-abbrev/plugin/abbrev).  It is made up of only lines like
these:

```
teh the
````

These are then added to vim as iabbrev definitions:

```
iabbrev teh the
````

It's not a grammar checker.  There's no way to fix transposition typos on
short words like f ro m / f or m, but it works well for longer words or those
that are difficult to spell.

The problem was that it takes time to source this list and with every
abbreviation added it takes vim longer to insert one, which blocks user input.
So instead of that, abbreviations are loading asynchronously in batches at a
delay with `timer_start`.  About 10 seconds after loading the package, it
should have sourced everything.

<p align="center"><img src="https://github.com/chris-ritsen/vim-autocorrect/blob/master/demo/description.gif?raw=true" alt="" title="vim-autocorrect description" width="474"/></p>

## Rules

Deleting the words in [abbrev](opt/vim-abbrev/plugin/abbrev) and starting from
scratch with any set of rules is an option, but the included list was created
by making every effort to avoid unintentional corrections.  Corrections should
prioritize the position of letters on a standard qwerty keyboard before
considering spelling mistakes.  Many typos are generated from timing errors
made by using both hands, especially if capitalization is involved.

### General

- Avoid adding short typos or words, such as those under four characters long.
- Avoid making decisions about mixed-case acronyms.
- Don't add contractions or word fragments.  `hadn` shouldn't correct to
  `hand` and no entry should exist for `shouldn` or `couldn`.
- Don't add words that are unlikely to broadly usable, such as camel case
  variable names.
- Don't pluralize words that weren't already pluralized.
- Prioritize compatibility with writing prose over code, but attempt to make
  it work with both if possible.
- Remove any autocorrection that results in a word that was unintended.
- Remove any typos that end up being programs, libraries, variables, names,
  nouns, brands, etc., but only when discovered.  For example, the program
  named `mosquitto` should not be corrected to `mosquito` and `msoquitto`
  should be corrected to `mosquitto`.
- Review recently added typos and check for errors.  Hastily adding them and
  assuming `spellsuggest` got it right isn't reliable.

### Spelling mistakes

- Add diacritical marks to letters only if the correct word is unambiguous.
  Correcting `Senor` to `Señor` is fine right up until `Senor` is written as a
  typo for `Sensor` or `Senior`.
- Don't change capitalization of words, as it could be part of a string
  literal or variable name.  `Paypal` should not be changed into `PayPal`.
  The word `I` should not corrected when `i` is typed.
- Don't attempt to localize/localise words.
- Don't enforce a preferred spelling.  `Eery` should not be corrected to
  `Eerie`.

### Typing mistakes

- Don't consider foreign words as typos, if known.
- Don't correct short words with a missing letter.
- Don't use this for expanding abbreviated words.  At most, this should be
  limited to a character or two omitted from the end of a long word, or a
  short word if the correct word is unambiguous.  Correcting `abou` to `about`
  is fine.
- No synthetic typos.
- Remove any leading characters from the previous word due to a mistimed
  spacebar press, unless they are valid words or used as variable names.  For
  example, `yto` might have been a misspelling of `toy` but it was actually a
  stray letter from a previous word prefixed to the word `to`.  The typo
  `atht` made by typing `at that` with a mistimed spacebar should not be
  corrected into `at` or `that`.


<p align="center"><img src="https://github.com/chris-ritsen/vim-autocorrect/blob/master/demo/rules.gif?raw=true" alt="" title="vim-autocorrect rules" width="474"/></p>

## Installation

This is a package of two vim plugins and should be installed to
`~/.vim/pack/vim-autocorrect`.  The
[autocorrect.vim](start/vim-abbrev-add/plugin/autocorrect.vim) plugin has
functions to interactively add abbreviations to the list.  By default, the
typos and their corrections are added to
[abbrev](opt/vim-abbrev/plugin/abbrev), but this can be overridden by setting
the variable `g:abbrev_file`.

```
let g:abbrev_file = expand('$HOME/.vim/pack/vim-autocorrect/opt/vim-abbrev/plugin/abbrev')
```


## Usage

To source the list of abbreviations (i.e., enable autocorrect):

```
:packadd vim-abbrev
```

This will take several seconds to load.

To quickly add abbreviations to the file after making typos, map the
`AutoCorrect` command like this:

```
nnoremap <silent> <leader>d <esc>vip:call AutoCorrect()<CR>
```

The `vip` here will select the current paragraph and pull out typos and use
the built-in `spellsuggest` feature to guess at a correction.  After pressing
`enter` or `<c-j>` to confirm the new abbreviations, they will be written to
the file and added with iabbrev.  Removal of words must be done manually.

If you need to write a word that would otherwise be autocorrected, such as
`teh`, type `<C-C>` or `<C-V>` after writing the word. `<C-C>` goes back to
normal mode without performing the correction, while `<C-V>` stays in insert
mode
