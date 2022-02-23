if exists('g:loaded_AutoCorrect')
  finish
endif

let g:loaded_AutoCorrect = 1

if !exists('g:abbrev_file')
  let g:abbrev_file = expand($HOME) . '/.vim/pack/vim-autocorrect/opt/vim-abbrev/plugin/abbrev'
endif

function! AddAbbrev(typo, correction, timer)
  execute 'silent! iab ' a:typo . ' ' . a:correction
endfunction

for line in readfile(g:abbrev_file, '')
  let tuple = split(line, " ")
  let typo = tuple[0]
  let correction = tuple[1]
  call timer_start(rand() % 50000, function('AddAbbrev', [typo, correction]))
endfor
