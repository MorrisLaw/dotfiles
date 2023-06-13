set number
set relativenumber
syntax enable
filetype plugin indent on

call plug#begin('~/.local/share/nvim/site/plugged')
Plug 'rust-lang/rust.vim'
Plug 'shaunsingh/nord.nvim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'preservim/nerdtree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

colorscheme nord

" Start NERDTree. If a file is specified, move the cursor to its window.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif

" Exit NeoVim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Switch between tabs using Ctrl <- and Ctrl ->
nnoremap H gT
nnoremap L gt
