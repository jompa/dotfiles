" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
set encoding=utf-8 " Necessary to show Unicode glyphs

" Reload vimrc on save
"autocmd! bufwritepost .vimrc source %
" Setting up Vundle - the vim plugin bundler

let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme)
    echo "Installing Vundle..."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
    let iCanHazVundle=0
endif

filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()


" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

" Better file browser
Bundle 'scrooloose/nerdtree'
" Code commenter
Bundle 'scrooloose/nerdcommenter'
let g:NERDAltDelims_javascript = 2
" Code and files fuzzy finder
Bundle 'ctrlpvim/ctrlp.vim'
" max number of mru entries, if it gets too large it takes time to load it
let g:ctrlp_mruf_max = 50

"Vim Airline
Bundle 'vim-airline/vim-airline'

" Terminal Vim with 256 colors colorscheme
Bundle 'fisadev/fisa-vim-colorscheme'
Bundle 'davb5/wombat256dave'
Bundle 'jpo/vim-railscasts-theme'

" True color
Bundle 'lifepillar/vim-solarized8'

" Surround
Bundle 'tpope/vim-surround'
" Git diff icons on the side of the file lines
Bundle 'airblade/vim-gitgutter'
" Autocompletion
"Bundle 'AutoComplPop'
Bundle 'rking/ag.vim'

" Syntax
Plugin 'w0rp/ale'
" Erlang
"Bundle 'jimenezrick/vimerl'
" Elixir
"Bundle 'elixir-lang/vim-elixir'
" Elm
"Bundle 'lambdatoast/elm.vim'
" Golang
Bundle 'fatih/vim-go'

" Typescript
Bundle 'leafgarland/typescript-vim'

Bundle 'jlanzarotta/bufexplorer'

" Git
Bundle 'tpope/vim-fugitive'

" Tmux integration
"Bundle 'jpalardy/vim-slime'

" Installing plugins the first time
if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif


" Asynchronous Lint Engine (ALE)
" Limit linters used for JavaScript.
let g:ale_linters = {
\  'javascript': ['flow', 'eslint'],
\}
highlight clear ALEErrorSign " otherwise uses error bg color (typically red)
highlight clear ALEWarningSign " otherwise uses error bg color (typically red)
let g:ale_sign_error = 'X' " could use emoji
let g:ale_sign_warning = '?' " could use emoji
let g:ale_statusline_format = ['X %d', '? %d', '']
" %linter% is the name of the linter that provided the message
" %s is the error or warning message
let g:ale_echo_msg_format = '%linter% says %s'
" Map keys to navigate between lines with errors and warnings.
nnoremap <leader>an :ALENextWrap<cr>
nnoremap <leader>ap :ALEPreviousWrap<cr>

" allow plugins by file type
filetype plugin indent on  " load filetype plugin
"filetype indent on  " load filetype plugen

set whichwrap+=<,>,h,l

set cursorline
" Set to auto read when a file is changed from the outside
set spell
set autoread
" Disable backupfiles
set nobackup
set nowritebackup
set noswapfile

set wildignore+=*/.git/*,*/.DS_Store,*/node_modules/*

set history=700
set gdefault


" ----------------------------------------------------------------------------
"  Mappings
" ----------------------------------------------------------------------------

" Rebind <Leader> key
let mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" Map space to / (search)
map - /
map ' /

" Exit insert mode without ESC
imap <C-c> <esc>

" Console ergonomics
map ö :
map ; :

set backspace=indent,eol,start

" Quick navigation
map <C-l> $
map <C-h> 0
" Ag
map <leader>a <Esc>:Ag
"set grepprg=ack\ --nogroup\ $*

" ----------------------------------------------------------------------------
" NerdTools
" ----------------------------------------------------------------------------
map <leader><Space> <leader>c<Space>
map <silent> <leader>n :NERDTreeToggle<CR>
" Find current file in NerdTree
map <silent> <leader>N :NERDTreeFind<CR>
let NERDTreeShowHidden=1
" Exclude files
let NERDTreeIgnore = ['\.pyc$','__pycache__[[dir]]']
let g:NERDAltDelims_javascript = 2

" ----------------------------------------------------------------------------
" CtrlP (new fuzzy finder)
" ----------------------------------------------------------------------------
let g:ctrlp_map = ',e'
" max number of mru entries, if it gets too large it takes time to load it
let g:ctrlp_mruf_max = 50
"nmap <leader>g :CtrlPBufTag<CR>
"nmap <leader>G :CtrlPBufTagAll<CR>
"nmap <leader>f :CtrlPLine<CR>
nmap <leader>f :CtrlPBuffer<CR>
nmap <leader>m :CtrlPMRUFiles<CR>

"
" Buffers
"
"map <leader>v :bnext<CR>
"map <leader>c :bprevious<CR>
map <leader>b :BufExplorer<CR>


"let g:BufferListWidth = 25
"let g:BufferListMaxWidth = 50
"hi BufferSelected term=reverse ctermfg=white ctermbg=red cterm=bold
"hi BufferNormal term=NONE ctermfg=black ctermbg=darkcyan cterm=NONE



" ----------------------------------------------------------------------------
" Vim-go
" ----------------------------------------------------------------------------
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1

" ----------------------------------------------------------------------------
"  Text Formatting
" ----------------------------------------------------------------------------

set expandtab              " expand tabs to spaces
set softtabstop=2
set shiftwidth=4           " distance to shift lines with < and >
set tabstop=4                   " tab character display size
set smarttab

set lbr
set tw=500

set autoindent "Auto indent
set smartindent "Smart indent
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab
"set wrap "Wrap lines
" ----------------------------------------------------------------------------
"  Visual Cues
" ----------------------------------------------------------------------------

syntax on                  " enable syntax highlighting
let loaded_matchparen=1    " don't hightlight matching brackets/braces
set laststatus=2           " always show the status line
set hlsearch               " highlight all search terms
set incsearch              " highlight search text as entered
set ignorecase             " ignore case when searching
set smartcase              " case sensitive only if capitals in search term
set colorcolumn=80        " not available until Vim 7.3
set visualbell             " shut the
set showmatch
set number
set cursorline

" Hightlight cursorline
hi CursorLine term=bold cterm=bold guibg=Grey40
hi Cursor guibg=#0087ad

" Hightlight colum 120 and beyond
"let &colorcolumn="80,".join(range(120,999),",")
"
" Highlight trailing whitespace
"hi ExtraWhitespace ctermbg=darkgreen guibg=#A30008
"match ExtraWhitespace /\s\+\%#\@<!$/
" ----------------------------------------------------------------------------
"  Graphical
" ----------------------------------------------------------------------------
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)

"solarized if you use "set termguicolors".
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

"let g:solarized_termcolors=256
colorscheme solarized8
set background=dark


let s:uname = system("uname")
if s:uname == "Darwin\n"
  set guifont=Inconsolata\ for\ Powerline:h15
else                         " on Ubunt
  set guifont=Monospace\
endif

" ----------------------------------------------------------------------------
"  Slime
" ----------------------------------------------------------------------------
"let g:slime_target = "tmux"
"xmap <leader>s <Plug>SlimeRegionSend
"nmap <leader>s <Plug>SlimeParagraphSend
