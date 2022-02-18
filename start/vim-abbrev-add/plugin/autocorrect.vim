
function! s:get_word(something)
  setlocal spell

  let s:badword = spellbadword(a:something)
  let corrections = {}

  " FIXME: Screws up around contractions.

  while empty(s:badword) == 0
    " echo s:badword
    " echo items(corrections)

    " Not a complete fix
    if has_key(corrections, s:badword[0]) == 1
      break
    endif

    if s:badword[1] == 'bad'
      let s:suggestion = spellsuggest(s:badword[0], 5)

      let key = s:badword[0]
      let value = s:suggestion[0]

      if empty(matchstr(key, "'")) == 1 && matchstr(value, "'s$") == "'s"
        let value = s:suggestion[1]
      endif

      if empty(matchstr(value, " ")) == 0
        let value = s:suggestion[1]
      endif

      let corrections[key] = value
    endif

    if s:badword[0] == ''
      let s:badword = []
    else
      let words = split(a:something, s:badword[0])

      if len(words) == 1
        let next_words = words[0:-1]
      else
        let next_words = words[1:-1]
      endif

      let s:badword = spellbadword(string(next_words))
    endif
  endwhile

  return corrections
endfunction

function! s:AC_commit()
  unlet! s:corrections
  unlet! s:thing

  let s:lines = getline(1, line('$'))
  let s:corrections = {}

  for line in s:lines
    let s:thing = split(line, ' ')
    let s:corrections[s:thing[0]] = s:thing[1]
  endfor

  close
  exe 'sb ' . g:AC_last_buffer

  for key in keys(s:corrections)
    " What about when a partial incorrect word replaces something in another
    " word to create an erroneous result?

    execute g:begin_line . "," . g:end_line . " substitute /" . key . "/" . s:corrections[key] . "/ge"

    let incorrect_word = key
    let correct_word = s:corrections[key]

    let abbrev_entry = 'iab ' . incorrect_word . ' ' . correct_word
    let abbrev_file = '/home/chris/.vim/pack/abbrev/opt/vim-abbrev/plugin/abbrev.vim'
    let s:abbrev_file = '/home/chris/.vim/pack/abbrev/opt/vim-abbrev/plugin/abbrev.vim'
    let s:lines = [abbrev_entry]
    call writefile(readfile(s:abbrev_file)+s:lines, s:abbrev_file)
    execute 'iab ' incorrect_word . ' ' . correct_word
  endfor

  execute 'wincmd _'
  normal! }zz
endfunction

function! AC(...) range
  unlet! g:begin_line
  unlet! g:end_line
  unlet! s:corrections

  let s:corrections = {}
  let s:lines = getline(a:firstline, a:lastline)

  let g:begin_line = a:firstline
  let g:end_line = a:lastline
  let g:AC_last_buffer = bufnr('%')
  let bname = '__Autocorrect__'
  let winnum = bufwinnr(bname)

  if winnum != -1
    if winnr() != winnum
      exe winnum . 'wincmd w'
    endif

    setlocal modifiable

    silent! %delete _
  else
    let bufnum = bufnr(bname)

    if bufnum == -1
      let wcmd = bname
    else
      let wcmd = '+buffer' . bufnum
    endif

    exe 'silent! botright ' . 8 . 'split ' . wcmd
  endif

  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal noswapfile
  setlocal nowrap
  setlocal nobuflisted
  setlocal winfixheight

  let old_cpoptions = &cpoptions
  set cpoptions&vim

  let &cpoptions = old_cpoptions


  " TODO: Clean up more of the junk left-over from the MRU window-open script.

  if a:0 == 0
    let m = copy(s:lines)
  else
    let m = filter(copy(s:lines), 'stridx(v:val, a:1) != -1')

    if len(m) == 0
      let m = filter(copy(s:lines), 'v:val =~# a:1')
    endif
  endif

  unlet! s:thing

  for line in m
    let s:thing = s:get_word(line)

    for k in keys(s:thing)
      let s:corrections[k] = s:thing[k]
    endfor
  endfor

  for key in keys(s:corrections)
    let output = key . ' ' . s:corrections[key]
    silent! 0put =output
  endfor

  if len(keys(s:corrections)) == 0
    close
    exe 'sb ' . g:AC_last_buffer

    " Not really ideal

    execute 'wincmd _'
    normal! }zz
    return
  endif

  $delete

  normal! gg

  setlocal modifiable
  setlocal spell
  nnoremap <buffer> <silent> <CR> :call <SID>AC_commit()<CR>
  nnoremap <buffer> <silent> <C-j> :call <SID>AC_commit()<CR>
  nnoremap <buffer> <silent> q :close<CR>:exe 'sb ' . g:AC_last_buffer<CR>
  nnoremap <buffer> <silent> <C-c> :close<CR>:exe 'sb ' . g:AC_last_buffer<CR> 

  " TODO: Don't even create the buffer if there is nothing to do.

endfunction

function! s:BufferIsEmpty()
  if line('$') == 1 && getline(1) == '' 
    return 1
  else
    return 0
  endif
endfunction

command! -bar -nargs=0 -range=% AC <line1>,<line2>call AC()

nnoremap <silent> <leader>d <esc>vip:call AC()<CR>

autocmd FileType denite call s:denite_my_settings()

function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
endfunction
