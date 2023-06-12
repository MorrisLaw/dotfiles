set number
set relativenumber
syntax enable
filetype plugin indent on

call plug#begin('~/.local/share/nvim/site/plugged')
Plug 'rust-lang/rust.vim'
Plug 'shaunsingh/nord.nvim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'preservim/nerdtree'
call plug#end()

colorscheme nord
