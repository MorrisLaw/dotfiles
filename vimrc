set number
set relativenumber
syntax enable
filetype plugin indent on

call plug#begin('~/.local/share/nvim/site/plugged')
Plug 'rust-lang/rust.vim'
Plug 'shaunsing/nord.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

colorscheme nord
