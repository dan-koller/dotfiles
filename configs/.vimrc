"""""""""""""
" Plugins
"""""""""""""
call plug#begin()
Plug 'cocopon/iceberg.vim'
Plug 'sheerun/vim-polyglot' " May cause issues with neovim
Plug 'luochen1990/rainbow'
Plug 'itchyny/lightline.vim'
Plug 'vim-syntastic/syntastic'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
call plug#end()

"""""""""""""
" Theme
"""""""""""""
set t_Co=256
set background=dark
colorscheme iceberg

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }

"""""""""""""
" Visuals
"""""""""""""
syntax on
set visualbell
set laststatus=2    " File name in statusbar
set hlsearch        " Highlight search results
set incsearch
set cursorline
hi clear CursorLine " Set underline in theme
hi CursorLine gui=underline cterm=underline

"""""""""""""
" Editing
"""""""""""""
set number          " Position in code
set ruler
set signcolumn=yes
set encoding=utf-8  " Default file encoding
set wrap            " Line wrap
set autoindent      " Auto + smart indent for code
set smartindent
set mouse=r         " Mouse support for copy and paste
set ts=4            " Default tab width
set tabstop=4
set shiftwidth=4

"""""""""""""
" Misc
"""""""""""""
set nobackup        " Disable backup files
set nowritebackup
set updatetime=300  " Reduce delay

"""""""""""""
" Functions
"""""""""""""
function! SetTab(n) " Set tab width to n spaces
    let &l:tabstop=a:n
    let &l:softtabstop=a:n
    let &l:shiftwidth=a:n
    set expandtab
endfunction
command! -nargs=1 SetTab call SetTab(<f-args>)

function! Trim()    " Trim extra whitespace in whole file
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
command! -nargs=0 Trim call Trim()

function! GitBranch() " Retrieve current git branch to display in statusbar
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction