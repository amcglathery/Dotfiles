" VIMRC (pieces picked from multiple sources, primarily
" "   http://www.vim.org/scripts/script.php?script_id=760
" "   http://amix.dk/vim/vimrc.html
" "   http://stackoverflow.com/questions/164847/what-is-in-your-vimrc
"
" " Catered to the needs and woes of a Tufts University Comp40 student
" " Contact Marshall @ mmoutenot@gmail.com with questions or comments.
"

"{{{Auto Commands

" Remove any trailing whitespace that is in the file
autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

" Restore cursor position to where it was before
augroup JumpCursorOnEdit
   au!
   autocmd BufReadPost *
            \ if expand("<afile>:p:h") !=? $TEMP |
            \   if line("'\"") > 1 && line("'\"") <= line("$") |
            \     let JumpCursorOnEdit_foo = line("'\"") |
            \     let b:doopenfold = 1 |
            \     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
            \        let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
            \        let b:doopenfold = 2 |
            \     endif |
            \     exe JumpCursorOnEdit_foo |
            \   endif |
            \ endif
   " Need to postpone using "zv" until after reading the modelines.
   autocmd BufWinEnter *
            \ if exists("b:doopenfold") |
            \   exe "normal zv" |
            \   if(b:doopenfold > 1) |
            \       exe  "+".1 |
            \   endif |
            \   unlet b:doopenfold |
            \ endif
augroup END

"}}}

"{{{Misc Settings

":make runs this script!
set makeprg=./compile

" Necessary for a lot of cool vim things
set nocompatible

" This shows what you are typing as a command at the bottom of the page
set showcmd
set cmdheight=2

" Folding Stuffs
" I find this one a little annoying sometimes set foldmethod=marker
set wrap
set textwidth=79
set formatoptions=qrn1

" Syntax Higlighting
filetype on
filetype plugin on
filetype indent on

" read a file when it is changed from the outside
set autoread

" Use grep
set grepprg=grep\ -nH\ $*

" AutoIndent
set autoindent

" Complete CSS
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

" Change spaces to a tab character
set expandtab
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2

" 4 spaces for java
autocmd FileType java setlocal shiftwidth=4 tabstop=4 softtabstop=4

" Spell checking (default=false)
if version >= 700
    set spl=en spell
    set nospell
endif

" Tab completion
set wildmenu
set wildmode=list:longest,full

set backspace=2

" Always show line numbers and current position
set ruler
set number

" Case handling
set ignorecase
set smartcase

" Incremental search
set incsearch
set hlsearch
set nolazyredraw
nnoremap / /\v
vnoremap / /\v

set gdefault

" For linux clipboard register
let g:clipbrdDefaultReg = '+'

" Second paren
highlight MatchParen ctermbg=4

"}}}


"{{{Look and Feel and sound
syntax enable "Enable syntax hl

" Set font according to system
" if you're using a mac
  "set gfn=Menlo:h14
  "set shell=/bin/bash

" if you're using windows
  "set gfn=Bitstream\ Vera\ Sans\ Mono:h10

" if you're using linux
  set gfn=Monospace\ 10
  set shell=/bin/bash

syntax enable "Enable syntax h1

syntax enable "Enable highlighting
set guioptions-=T
set t_Co=256
set background=dark
set nonu
set encoding=utf8

try
    lang en_US
catch
endtry

set ffs=unix,dos,mac "Default file types

"Status line gnarliness
set laststatus=2
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c
function! CurDir()
    let curdir = substitute(getcwd(), '/Users/amir/', "~/", "g")
    return curdir
endfunction
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    else
        return ''
    endif
endfunction

" No sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" }}}

"{{{Functions

"{{{ Open URL in Browser

function! Browser()
    let line = getline (".")
    let line = matchstr (line,"http[^  ]*")
    exec "!chrome ".line
endfunction

"}}}

"{{{ Todo List Mode

function! TodoListMode()
    e ~/.todo.otl
    Calendar
    wincmd l
    set foldlevel=1
    tabnew ~/.notes.txt
    tabfirst
    or 'norm! zMzr'
endfunction

"}}}

"{{{ Persistant Undo
    "if windows
      "set undodir=C:\Windows\Temp
    "otherwise
    if version >720
        set undodir=~/.vim_runtime/undodir
        set undofile
    endif
"}}}

"}}}

"{{{ Mappings

" Remap leader key
let mapleader=","

" Open Url with the browser \w
map <Leader>w :call Browser ()<CR>

" Trigger the above todo mode
noremap <silent> <Leader>todo :execute TodoListMode()<CR>

" clear search quickly
map <Leader><space> :noh<cr>

" edit vimrc quickly
map <Leader>ev :vsp $MYVIMRC<cr><C-w>w

" git leader commands
noremap <Leader>ga :!git add %<cr>
noremap <Leader>gc :!git commit -m "
noremap <Leader>gs :!git status<cr>

" wrap current word in quotes
noremap <Leader>' ciw'<C-r>"'<Esc>
noremap <Leader>" ciw"<C-r>""<Esc>

" map escape to something easier
imap jj <Esc>

" Next Tab
noremap <silent> <C-Right> :tabnext<CR>
" Previous Tab
noremap <silent> <C-Left> :tabprevious<CR>
" New Tab
noremap <silent> <C-t> :tabnew<CR>

" Centers the next result on the page
map N Nzz
map n nzz

" Swap ; and : (one less keypress)
nnoremap ; :

function! DelEmptyLineAbove()
    if line(".") == 1
        return
    endif
    let l:line = getline(line(".") - 1)
    if l:line =~ '^\s*$'
        let l:colsave = col(".")
        .-1d
        silent normal! <C-y>
        call cursor(line("."), l:colsave)
    endif
endfunction

function! AddEmptyLineAbove()
    let l:scrolloffsave = &scrolloff
    " Avoid jerky scrolling with ^E at top of window
    set scrolloff=0
    call append(line(".") - 1, "")
    if winline() != winheight(0)
        silent normal! <C-e>
    endif
    let &scrolloff = l:scrolloffsave
endfunction

function! DelEmptyLineBelow()
    if line(".") == line("$")
        return
    endif
    let l:line = getline(line(".") + 1)
    if l:line =~ '^\s*$'
        let l:colsave = col(".")
        .+1d
        ''
        call cursor(line("."), l:colsave)
    endif
endfunction

function! AddEmptyLineBelow()
    call append(line("."), "")
endfunction

" Arrow key remapping: Up/Dn = move line up/dn; Left/Right = indent/unindent
function! SetArrowKeysAsTextShifters()
    " normal mode
    nmap <silent> <Left> <<
    nmap <silent> <Right> >>
    nnoremap <silent> <Up> <Esc>:call DelEmptyLineAbove()<CR>
    nnoremap <silent> <Down>  <Esc>:call AddEmptyLineAbove()<CR>
    nnoremap <silent> <C-Up> <Esc>:call DelEmptyLineBelow()<CR>
    nnoremap <silent> <C-Down> <Esc>:call AddEmptyLineBelow()<CR>

    " visual mode
    vmap <silent> <Left> <
    vmap <silent> <Right> >
    vnoremap <silent> <Up> <Esc>:call DelEmptyLineAbove()<CR>gv
    vnoremap <silent> <Down>  <Esc>:call AddEmptyLineAbove()<CR>gv
    vnoremap <silent> <C-Up> <Esc>:call DelEmptyLineBelow()<CR>gv
    vnoremap <silent> <C-Down> <Esc>:call AddEmptyLineBelow()<CR>gv

    " insert mode
    imap <silent> <Left> <C-D>
    imap <silent> <Right> <C-T>
    inoremap <silent> <Up> <Esc>:call DelEmptyLineAbove()<CR>a
    inoremap <silent> <Down> <Esc>:call AddEmptyLineAbove()<CR>a
    inoremap <silent> <C-Up> <Esc>:call DelEmptyLineBelow()<CR>a
    inoremap <silent> <C-Down> <Esc>:call AddEmptyLineBelow()<CR>a

    " disable modified versions we are not using
    nnoremap  <S-Up>     <NOP>
    nnoremap  <S-Down>   <NOP>
    nnoremap  <S-Left>   <NOP>
    nnoremap  <S-Right>  <NOP>
    vnoremap  <S-Up>     <NOP>
    vnoremap  <S-Down>   <NOP>
    vnoremap  <S-Left>   <NOP>
    vnoremap  <S-Right>  <NOP>
    inoremap  <S-Up>     <NOP>
    inoremap  <S-Down>   <NOP>
    inoremap  <S-Left>   <NOP>
    inoremap  <S-Right>  <NOP>
endfunction

call SetArrowKeysAsTextShifters()

" Commands with leader key

" Save on focus lost
au FocusLost * :wa
