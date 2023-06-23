" 使用说明:
" => 创建 ~/.vim/swap 目录
" => 打开 vim, 执行 PlugInstall

" ------------------------------------------------------ {{{

syntax on                  " Enable syntax highlighting.
filetype plugin indent on  " Enable file type based indentation.
colorscheme murphy         " Change a colorscheme.

set number                      " Display column numbers.
set autoindent             " Respect indentation when starting a new line.
set expandtab              " Expand tabs to spaces. Essential in Python.
set tabstop=4              " Number of spaces tab is counted for.
set shiftwidth=4           " Number of spaces to use for autoindent.
set backspace=2            " Fix backspace behavior on most terminals.

set foldmethod=indent           " Indentation-based folding.
set wildmenu                    " Enable enhanced tab autocomplete.
set wildmode=list:longest,full  " Complete till longest string, then open menu.

set directory=~/.vim/swap//

set hlsearch                    " Highlight search results.
set incsearch                   " Search as you type.
set clipboard=unnamed,unnamedplus  " Copy into system (*, +) registers.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" => Advance Monvement and Navigation <= """
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Navigate windows with <Ctrl-hjkl> instead of <Ctrl-w> followed by hjkl.
noremap <c-h> <c-w><c-h>
noremap <c-j> <c-w><c-j>
noremap <c-k> <c-w><c-k>
noremap <c-l> <c-w><c-l>

" noremap <c-u> :w<cr>  " Save using <Ctrl-u> (u stands for update).

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

Plug 'tpope/vim-unimpaired'
Plug 'easymotion/vim-easymotion'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mhinz/vim-startify'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'yggdroot/indentline'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-vinegar'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-commentary'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }

call plug#end()

" Gundo Config
noremap <f5> :GundoToggle<cr>  " Map Gundo to <F5>.

" Python-mode Config
let g:pymode_python = 'python3'
let g:pymode_trim_whitespaces = 1
let g:pymode_doc = 1
let g:pymode_doc_bind = 'K'
let g:pymode_rope_goto_definition_bind = '<c-]'
let g:pymode_lint = 1
let g:pymode_lint_checkers = ['pyflakes', 'pep8', 'mccabe', 'pylint']
let g:pymode_options_max_line_length = 120