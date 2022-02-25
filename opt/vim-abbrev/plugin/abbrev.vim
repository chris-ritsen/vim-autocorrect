if exists('g:loaded_AutoCorrect')
  finish
endif

let g:loaded_AutoCorrect = 1

if !exists('g:abbrev_file')
  let g:abbrev_file = expand($HOME) . '/.vim/pack/vim-autocorrect/opt/vim-abbrev/plugin/abbrev'
endif

let s:t = reltime()

func FilterBad(index, value)
  return len(split(a:value)) == 2
endfunc

let s:data = filter(readfile(g:abbrev_file), function('FilterBad'))

let s:sz = 50

func! s:DefAbbrevs(i = 0) abort
    exe s:data[a:i : a:i + s:sz - 1]->map({_, v -> 'ia ' .. v})->join('|')

    if a:i + s:sz < s:data->len()
        call timer_start(1, {-> s:DefAbbrevs(a:i + s:sz)})
    else
        " echom 'Finished defining abbreviations in' reltimestr(reltime(s:t)) 's'
        unlet s:t s:sz s:data
    endif
endfunc

call s:DefAbbrevs()
