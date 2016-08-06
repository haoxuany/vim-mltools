
if exists("g:loaded_mltools") || &cp || v:version < 700
  finish
endif
let g:loaded_mltools = 1

" variables
function! s:stringify(value)
  " String
  if type(a:value) == 1
    let l:value = '"' . a:value . '"'
  else
    let l:value = string(a:value)
  endif
  return l:value
endfunction

function! s:default(variable, value)
  if !exists(a:variable)
    execute 'let ' . a:variable . ' = ' . s:stringify(a:value)
  endif
endfunction

function! s:canset(variable)
endfunction

" mltools variables
call s:canset('g:mlt_cm_file')

" mltc variables
call s:default('g:mltc', 'mltc')

" mltq variables
call s:default('g:mltq', 'mltq')
call s:default('g:mltq_options', ["--nodebug", "--query", "--fuzzy"])

" mlcp variables
call s:default('g:mlcp', 'mlcp')
call s:default('g:mlcp_options', ["--nodebug"])


" mltools functions
function! s:run_cmd(cmd)
  echom substitute(system(a:cmd), '\n\+$', '', '')
endfunction

function! s:is_cm_file(cmfile)
  if getftype(a:cmfile) != 'file' && getftype(a:cmfile) != 'link'
    echom a:cmfile . ' not found or is not a file!'
    return 0
  elseif a:cmfile !~ '\v.*\.cm$'
    echom a:cmfile . ' is not a CM file! Please specify another file'
    return 0
  endif
  return 1
endfunction

function! s:set_cm_file(cmfile)
  if a:cmfile == ""
    if expand('%:e') == "cm"
      let l:cmfile = bufname('%')
    else
      echom 'Current file is not a CM file! Please specify another file.'
      return 0
    endif
  elseif s:is_cm_file(a:cmfile)
    let l:cmfile = a:cmfile
  else
    return 0
  endif

  let g:mlt_cm_file = l:cmfile
  let b:mlt_cm_file = l:cmfile
  echom 'CM file set to ' . l:cmfile
  return 1
endfunction

function! s:prompt_cm_file()
  let l:cmfile = input(':MltSetCM ', '', 'file')
  redraw!
  return s:set_cm_file(l:cmfile)
endfunction



" mltq functions
function! s:get_byte(mark)
  return line2byte(line(a:mark)) + col(a:mark) - 2
endfunction

function! s:mltq()
  if !exists('b:mlt_cm_file')
    if !exists('g:mlt_cm_file')
      echom 'CM file has never been specified!'
      if s:prompt_cm_file()
        sleep 1
        redraw!
        call s:mltq()
      endif
      return
    else
      let l:cmfile = g:mlt_cm_file
    endif
  else
    let l:cmfile = b:mlt_cm_file
  end
  if !s:is_cm_file(l:cmfile)
    call s:prompt_cm_file()
  endif

  let l:cmd_params = [g:mltq, l:cmfile, bufname('%')] +
        \g:mltq_options +
        \[s:get_byte("'<"), s:get_byte("'>")]
  let l:cmd = ''
  for param in l:cmd_params
    let l:cmd .= param . ' '
  endfor
  call s:run_cmd(l:cmd)
endfunction

vnoremap <silent> <Plug>VMltq :<C-U>call <SID>mltq()<CR>

command! -nargs=? -complete=file MltSetCM call s:set_cm_file(<q-args>)
command! -nargs=0 Mltq call s:mltq()

xmap <leader>q <Plug>VMltq

" vim: set ft=vim ts=2 sts=2 sw=2 et:
