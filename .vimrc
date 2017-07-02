execute pathogen#infect()
syntax on             " Enable syntax highlighting

filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins
filetype plugin indent on

set nocompatible
set tabstop=2 shiftwidth=2 softtabstop=2
set expandtab
set autoindent
set smartindent
set incsearch
set showmatch
set nofoldenable

map <C-t> :tabnew<CR>
map <S-Tab> :tabp<CR>
map <Tab> :tabn<CR>
map <C-;> <C-w><Left>
map <C-'> <C-w><Right>

au BufNewFile,BufRead *.go set filetype=go
au BufNewFile,BufRead *.sls set filetype=scheme
let g:rust_recommended_style = 0

set t_Co=256
