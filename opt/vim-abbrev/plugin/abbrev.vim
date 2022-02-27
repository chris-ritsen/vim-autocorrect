if exists('g:loaded_AutoCorrect')
  finish
endif

let g:loaded_AutoCorrect = 1

if !exists('g:abbrev_file')
  let g:abbrev_file = expand('~/.vim/pack/vim-autocorrect/opt/vim-abbrev/plugin/abbrev')
endif

function FilterBad(index, value)
  return len(split(a:value)) == 2
endfunc

let s:time = reltime()
let s:abbrevs_added = 0
let s:data = filter(readfile(g:abbrev_file), function('FilterBad'))
let s:batch_size = 5000
let s:delay_ms = 1

function s:Callback(start_line)
  return {-> s:DefineAbbrevs(a:start_line)}
endfunction

let s:map_corrections = {_, correction_dyad -> 'iabbrev ' .. correction_dyad}

function! s:DefineAbbrevs(start_line = 0) abort
  " As the list of inserted abbreviations grows, vim takes more time to insert
  " a new abbreviation.  Tune the batch size as the list grows to react to
  " this effect to process as many lines as possible without perceivably
  " blocking UI.

  if a:start_line >= 5000 && s:batch_size != 400
    let s:batch_size = 400
    " echomsg 'Batch size changed to' s:batch_size
  endif

  if a:start_line > 10000 && s:batch_size != 300
    let s:batch_size = 300
    " echomsg 'Batch size changed to' s:batch_size
  endif

  if a:start_line > 20000 && s:batch_size != 225
    let s:batch_size = 225
    " echomsg 'Batch size changed to' s:batch_size
  endif

  if a:start_line > 30000 && s:batch_size != 150
    let s:batch_size = 150
    " echomsg 'Batch size changed to' s:batch_size
  endif

  if a:start_line > 40000 && s:batch_size != 125
    let s:batch_size = 125
    " echomsg 'Batch size changed to' s:batch_size
  endif

  if a:start_line > 45000 && s:batch_size != 120
    let s:batch_size = 120
    " echomsg 'Batch size changed to' s:batch_size
  endif

  if a:start_line > 50000 && s:batch_size != 110
    let s:batch_size = 110
    " echomsg 'Batch size changed to' s:batch_size
  endif

  if a:start_line > 60000 && s:batch_size != 90
    let s:batch_size = 90
    " echomsg 'Batch size changed to' s:batch_size
  endif

  if a:start_line > 70000 && s:batch_size != 50
    let s:batch_size = 50
    " echomsg 'Batch size changed to' s:batch_size
  endif

  let end_line = a:start_line + s:batch_size
  let lines = s:data[a:start_line : end_line - 1]

  execute lines->map(s:map_corrections)->join('|')
  let s:abbrevs_added = s:abbrevs_added + lines->len()

  if end_line < s:data->len()
    call timer_start(s:delay_ms, s:Callback(end_line))
  else
    " echomsg 'Finished defining' s:abbrevs_added 'abbreviation(s) in' reltimestr(reltime(s:time)) 's'
    unlet s:abbrevs_added s:batch_size s:data s:delay_ms s:time
  endif
endfunc

call s:DefineAbbrevs()
