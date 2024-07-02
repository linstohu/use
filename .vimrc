set number                        " Display column numbers.
set autoindent                    " Respect indentation when starting a new line.
set expandtab                     " Expand tabs to spaces. Essential in Python.
set tabstop=4                     " Number of spaces tab is counted for.
set shiftwidth=4                  " Number of spaces to use for autoindent.
set backspace=2                   " Fix backspace behavior on most terminals.
set foldmethod=indent             " Indentation-based folding.
set wildmenu                      " Enable enhanced tab autocomplete.
set wildmode=list:longest,full    " Complete till longest string, then open menu.
set hlsearch                      " Highlight search results.
set incsearch                     " Search as you type.
set clipboard=unnamed,unnamedplus " Copy into system (*, +) registers.

syntax on                  " Enable syntax highlighting.
filetype plugin indent on  " Enable file type based indentation.
colorscheme murphy         " Change a colorscheme.
let mapleader = ','        " Map the leader key to a comma.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" => Advance Monvement and Navigation <= """
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Navigate windows with <Ctrl-hjkl> instead of <Ctrl-w> followed by hjkl.
noremap <c-h> <c-w><c-h>
noremap <c-j> <c-w><c-j>
noremap <c-k> <c-w><c-k>
noremap <c-l> <c-w><c-l>

" Map arrow keys nothing so I can get used to hjkl-style movement.
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" => Plugin Management <= """
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Install vim-plug if it's not already installed (Unix-only).
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.github.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()  " Manage plugins with vim-plug.

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-vinegar'
Plug 'easymotion/vim-easymotion'
Plug 'ctrlpvim/ctrlp.vim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-unimpaired'
Plug 'yggdroot/indentline'
Plug 'tpope/vim-commentary'

" The Language Server Protocol (LSP)
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

call plug#end()

" NERDTree Config
nnoremap <leader>v :NERDTreeFind<CR>
nnoremap <leader>g :NERDTreeToggle<CR>

" Easymotion Config
nmap ss <Plug>(easymotion-s2)
