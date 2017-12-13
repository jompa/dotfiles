"Eagerly stolen from:
"https://github.com/alexreisner/dotfiles/blob/master/.vimrc
"https://github.com/mkotsalainen/dotvim/blob/master/vimrc

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
" Class/module browser
"Bundle 'majutsushi/tagbar'
" Code and files fuzzy finder
Bundle 'kien/ctrlp.vim'
" max number of mru entries, if it gets too large it takes time to load it
let g:ctrlp_mruf_max = 150
" Zen coding
" HTML
Bundle 'mattn/emmet-vim'
"Bundle 'kien/tabman.vim'
"Vim Airline
Bundle 'vim-airline/vim-airline'
" Powerline
"Bundle 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
"Bundle 'powerline/powerline'
" Terminal Vim with 256 colors colorscheme
Bundle 'fisadev/fisa-vim-colorscheme'
Bundle 'davb5/wombat256dave'
Bundle 'jpo/vim-railscasts-theme'
Bundle 'jpalardy/vim-slime'

" Consoles as buffers
"Bundle 'rosenfeld/conque-term'
" Pending tasks list
"Bundle 'fisadev/FixedTaskList.vim'
" Surround
Bundle 'tpope/vim-surround'
" Autoclose
"Bundle 'Townk/vim-autoclose'
" Indent text object
"Bundle 'michaeljsmith/vim-indent-object'
" Python mode (indentation, doc, refactor, lints, code checking, motion and
" operators, highlighting, run and ipdb breakpoints)
 "Bundle 'klen/python-mode'
" Snippets manager (SnipMate), dependencies, and snippets repo
"Bundle 'MarcWeber/vim-addon-mw-utils'
"Bundle 'tomtom/tlib_vim'
"Bundle 'honza/vim-snippets'
"Bundle 'garbas/vim-snipmate'
" Git diff icons on the side of the file lines
Bundle 'airblade/vim-gitgutter'
" Autocompletion
Bundle 'AutoComplPop'
" Search results counter
"Bundle 'IndexedSearch'
" XML/HTML tags navigation
"Bundle 'matchit.zip'
" Gvim colorscheme
"Bundle 'Wombat'
Bundle 'altercation/vim-colors-solarized'
Bundle 'rking/ag.vim'

" Syntax
" Erlang
"Bundle 'jimenezrick/vimerl'
" Elixir
"Bundle 'elixir-lang/vim-elixir'
" Elm
"Bundle 'lambdatoast/elm.vim'
" Golang
"Bundle 'fatih/vim-go'

Bundle 'jlanzarotta/bufexplorer'
Bundle 'duff/vim-bufonly'
Bundle 'tpope/vim-fugitive'
Plugin 'w0rp/ale'
"Bundle 'vim-syntastic/syntastic'

"let g:syntastic_auto_loc_list=1
"let g:syntastic_javascript_checkers = ['eslint', 'flow']
"let g:syntastic_javascript_flow_exe = 'flow'

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
"let g:syntastic_mode_map = { 'mode': 'passive' }
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

" Rebind <Leader> key
let mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" ----------------------------------------------------------------------------
"  Ctags
" ----------------------------------------------------------------------------
set tags=tags
"move into tags and back
map <silent><C-Left> <C-T>
map <silent><C-Right> <C-]>

"map <silent><leader>t <C-T>
"map <silent><leader>b <C-]>
"move between func defs
map <C-up> [[
map <C-down> ]]
" ----------------------------------------------------------------------------
"  Mappings
" ----------------------------------------------------------------------------

" Map space to / (search) and c-space to ? (backgwards search)
"map <space> /
map - /
"map <c-space> ?
"  exit insert mode
imap <C-c> <esc>
"inoremap <C-@> <esc>
"noremap <nul> <esc>
"inoremap <nul> <esc>
"noremap <c-space> <esc>
"inoremap <c-space> <esc>
"map <c-space> <c-c>

map ö :
map ä $
map å 0

map <leader>ä oimport ipdb; ipdb.set_trace()
set backspace=indent,eol,start

" split navigation
"map <C-up> <c-w>j
"""map <C-down> <c-w>k
"""map <C-right> <c-w>l
"""map <C-left> <c-w>h

" Append closing characters
"inoremap {      {}<Left>
"inoremap {<CR>  {<CR>}<Esc>O
"inoremap {{     {
"inoremap {}     {}

" Quick navigation
map <C-l> $
" Ag
map <leader>a <Esc>:Ag
"set grepprg=ack\ --nogroup\ $*

map <leader>t :TagbarToggle<CR>
map <leader><Space> <leader>c<Space>
map <silent> <leader>n :NERDTreeToggle<CR>
" Find current file in NerdTree
map <silent> <leader>N :NERDTreeFind<CR>
let NERDTreeShowHidden=1
" Exclude files
let NERDTreeIgnore = ['\.pyc$','__pycache__[[dir]]']

"Fuzzyfinder
"let g:fuf_file_exclude = '\v\~$|\.o$|\.exe$|\.bak$|\.swp|\.class$'
"map <leader>f :FufFile **/<CR>
" CtrlP (new fuzzy finder)
let g:ctrlp_map = ',e'
nmap <leader>g :CtrlPBufTag<CR>
nmap <leader>G :CtrlPBufTagAll<CR>
nmap <leader>f :CtrlPLine<CR>
"nmap <leader>b :CtrlPBuffer<CR>
nmap <leader>m :CtrlPMRUFiles<CR>

" Buffers
map <leader>v :bnext<CR>
map <leader>c :bprevious<CR>
map <leader>b :BufExplorer<CR>


"let g:BufferListWidth = 25
"let g:BufferListMaxWidth = 50
"hi BufferSelected term=reverse ctermfg=white ctermbg=red cterm=bold
"hi BufferNormal term=NONE ctermfg=black ctermbg=darkcyan cterm=NONE

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

set ai "Auto indent
set si "Smart indent
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
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
"set colorcolumn=80        " not available until Vim 7.3
set visualbell             " shut the fuck up
set showmatch
set number
set cursorline

" Hightlight cursorline
hi CursorLine term=bold cterm=bold guibg=Grey40
hi Cursor guibg=#0087ad
"hi ColorColumn ctermbg=lightgrey guibg=Grey20


" Hightlight colum 120 and beyond
"let &colorcolumn="80,".join(range(120,999),",")
" ----------------------------------------------------------------------------
"  Graphical
" ----------------------------------------------------------------------------

let g:solarized_termcolors=256
"set t_Co=256 " Explicitly tell Vim that the terminal supports 256 colors
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
set termencoding=utf-8
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
"colorscheme solarized
colorscheme railscasts
" use 256 colors in terminal
if !has("gui_running")
    set t_Co=256
    set term=screen-256color
endif"

if has('gui_running')
  set background=dark
  set guioptions-=T
  let g:Powerline_symbols = 'fancy'
else
  set background=light
endif


let s:uname = system("uname")
if s:uname == "Darwin\n"
  set guifont=Inconsolata\ for\ Powerline:h15
else                         " on Ubunt
  set guifont=Monospace\
endif

""""""""""""""""""""""""""""""
" => MRU plugin
""""""""""""""""""""""""""""""
"let MRU_Max_Entries = 400
"map <leader>f :MRU<CR>

" Colorscheme overrides
"hi ColorColumn ctermbg=lightgrey guibg=Grey20

" Highlight trailing whitespace
"hi ExtraWhitespace ctermbg=darkgreen guibg=#A30008
"match ExtraWhitespace /\s\+\%#\@<!$/

" ----------------------------------------------------------------------------
"  Slime
" ----------------------------------------------------------------------------
let g:slime_target = "tmux"
xmap <leader>s <Plug>SlimeRegionSend
nmap <leader>s <Plug>SlimeParagraphSend
