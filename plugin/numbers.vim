""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:           numbers.vim
" Maintainer:     Mahdi Yusuf yusuf.mahdi@gmail.com
" Version:        0.5.0
" Description:    vim global plugin for better line numbers.
" Last Change:    12 August, 2013
" License:        MIT License
" Location:       plugin/numbers.vim
" Website:        https://github.com/myusuf3/numbers.vim
"
" See numbers.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help numbers
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:numbers_version = '0.4.0'

if exists("g:loaded_numbers") && g:loaded_numbers
    finish
endif
let g:loaded_numbers = 1

if (!exists('g:enable_numbers'))
    let g:enable_numbers = 1
endif

if !exists('g:numbers_blacklist')
  " some sane defaults for blacklisting
  let g:numbers_blacklist = ['^NERD_tree_\d\+$', '^__Tagbar__$', '^__Gundo\(_Preview\)\?__$']
endif

if v:version < 703 || &cp
    echomsg "numbers.vim: you need at least Vim 7.3 and 'nocp' set"
    echomsg "Failed loading numbers.vim"
    finish
endif


"Allow use of line continuation
let s:save_cpo = &cpo
set cpo&vim

let s:mode=0
let s:center=1

function! NumbersRelativeOff()
    if v:version > 703 || (v:version == 703 && has('patch1115'))
        set norelativenumber
    else
        set number
    endif
endfunction

function! SetNumbers()
    let s:mode = 1
    call ResetNumbers()
endfunc

function! SetRelative()
    let s:mode = 0
    call ResetNumbers()
endfunc

function! NumbersToggle()
    if (s:mode == 1)
        let s:mode = 0
        set relativenumber
    else
        let s:mode = 1
        call NumbersRelativeOff()
    endif
endfunc

function! ResetNumbers()
    if(s:center == 0)
        call NumbersRelativeOff()
    elseif(s:mode == 0)
        set relativenumber
    else
        call NumbersRelativeOff()
    end
endfunc

function! Center()
    let s:center = 1
    call ResetNumbers()
endfunc

function! Uncenter()
    let s:center = 0
    call ResetNumbers()
endfunc

function! NumbersCheck(func)
  " decotrator for executing au commands only if buffer is not on blacklist
  let bufname = bufname('%')
  if empty(filter(copy(g:numbers_blacklist), 'match(bufname, v:val) != -1'))
    call function(a:func)()
  endif
endfunction

function! NumbersEnable()
    let g:enable_numbers = 1
    :set relativenumber
    augroup enable
        au!
        autocmd InsertEnter * :call NumbersCheck('SetNumbers')
        autocmd InsertLeave * :call NumbersCheck('SetRelative')
        autocmd BufNewFile  * :call NumbersCheck('ResetNumbers')
        autocmd BufReadPost * :call NumbersCheck('ResetNumbers')
        autocmd FocusLost   * :call NumbersCheck('Uncenter')
        autocmd FocusGained * :call NumbersCheck('Center')
        autocmd WinEnter    * :call NumbersCheck('SetRelative')
        autocmd WinLeave    * :call NumbersCheck('SetNumbers')
    augroup END
endfunc

function! NumbersDisable()
    let g:enable_numbers = 0
    :set nu
    :set nu!
    augroup disable
        au!
        au! enable
    augroup END
endfunc

function! NumbersOnOff()
    if (g:enable_numbers == 1)
        call NumbersDisable()
    else
        call NumbersEnable()
    endif
endfunc

" Commands
command! -nargs=0 NumbersToggle call NumbersToggle()
command! -nargs=0 NumbersEnable call NumbersEnable()
command! -nargs=0 NumbersDisable call NumbersDisable()
command! -nargs=0 NumbersOnOff call NumbersOnOff()

" reset &cpo back to users setting
let &cpo = s:save_cpo

if (g:enable_numbers)
    call NumbersEnable()
endif
