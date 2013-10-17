"Eagerly stolen from:
"https://github.com/alexreisner/dotfiles/blob/master/.vimrc
"https://github.com/mkotsalainen/dotvim/blob/master/vimrc

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

"set encoding=utf-8 " Necessary to show Unicode glyphs

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
Bundle 'majutsushi/tagbar'
" Code and files fuzzy finder
Bundle 'kien/ctrlp.vim'
" max number of mru entries, if it gets too large it takes time to load it
let g:ctrlp_mruf_max = 150
" Zen coding
Bundle 'mattn/zencoding-vim'
Bundle 'kien/tabman.vim'
" Powerline
Bundle 'Lokaltog/vim-powerline'
" Terminal Vim with 256 colors colorscheme
Bundle 'fisadev/fisa-vim-colorscheme'
" Consoles as buffers
Bundle 'rosenfeld/conque-term'
" Pending tasks list
Bundle 'fisadev/FixedTaskList.vim'
" Surround
Bundle 'tpope/vim-surround'
" Autoclose
Bundle 'Townk/vim-autoclose'
" Indent text object
Bundle 'michaeljsmith/vim-indent-object'
" Python mode (indentation, doc, refactor, lints, code checking, motion and
" operators, highlighting, run and ipdb breakpoints)
" Bundle 'klen/python-mode'
" Snippets manager (SnipMate), dependencies, and snippets repo
Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'tomtom/tlib_vim'
Bundle 'honza/vim-snippets'
Bundle 'garbas/vim-snipmate'
" Git diff icons on the side of the file lines
Bundle 'airblade/vim-gitgutter'
" Autocompletion
Bundle 'AutoComplPop'
" Search results counter
Bundle 'IndexedSearch'
" XML/HTML tags navigation
Bundle 'matchit.zip'
" Gvim colorscheme
Bundle 'Wombat'

Bundle 'rking/ag.vim'

Bundle 'jimenezrick/vimerl'

Bundle 'duff/vim-bufonly'
Bundle 'tpope/vim-fugitive'
Bundle 'scrooloose/syntastic'
Bundle 'kchmck/vim-coffee-script'

let g:syntastic_auto_loc_list=1

" Installing plugins the first time
if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif


" allow plugins by file type
let g:syntastic_mode_map = { 'mode': 'passive' }
filetype plugin on  " load filetype plugin
filetype indent on  " load filetype plugen

set whichwrap+=<,>,h,l

set cursorline
" Set to auto read when a file is changed from the outside
set spell
set autoread
" Disable backupfiles
set nobackup
set nowritebackup
set noswapfile

set history=700

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

map <leader>v :bnext<CR>
map <leader>c :bprevious<CR>
"map <silent><leader>t <C-T> 
"map <silent><leader>b <C-]> 
"move between func defs
map <C-up> [[
map <C-down> ]]
" ----------------------------------------------------------------------------
"  Mappings
" ----------------------------------------------------------------------------

" Map space to / (search) and c-space to ? (backgwards search)
map <space> /
map - /
map <c-space> ?
"  exit insert mode
imap jk <esc>

map ö :

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
map <C-j> jjjj
map <C-k> kkkk
map <C-l> 0
map <C-h> $

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
let NERDTreeIgnore = ['\.pyc$']

"Fuzzyfinder
"let g:fuf_file_exclude = '\v\~$|\.o$|\.exe$|\.bak$|\.swp|\.class$'
"map <leader>f :FufFile **/<CR>
" CtrlP (new fuzzy finder)
let g:ctrlp_map = ',e'
nmap ,g :CtrlPBufTag<CR>
nmap ,G :CtrlPBufTagAll<CR>
nmap ,f :CtrlPLine<CR>
nmap ,b :CtrlPBuffer<CR>
nmap ,m :CtrlPMRUFiles<CR>

" Buffers
map <leader>b :bp<CR>
map <leader>B :bn<CR>

" ----------------------------------------------------------------------------
"  Text Formatting
" ----------------------------------------------------------------------------

set expandtab              " expand tabs to spaces
set softtabstop=2
set shiftwidth=4           " distance to shift lines with < and >
set ts=4                   " tab character display size
set smarttab

set lbr
set tw=500

set ai "Auto indent
set si "Smart indet
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

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=darkgreen guibg=pink
match ExtraWhitespace /\s\+\%#\@<!$/
" ----------------------------------------------------------------------------
"  Graphical
" ----------------------------------------------------------------------------

set t_Co=256 " Explicitly tell Vim that the terminal supports 256 colors
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

if has('gui_running')
  "colorscheme molokai
  "colorscheme wombat 
  colorscheme jompa_wombat 
  set guioptions-=T
  if system("uname") == "Darwin\n" " on OSX
    set guifont=Menlo:h14 "set lines=55
    "set columns=94
  else                         " on Ubuntu
    set guifont=Monospace\ 9
    "winpos 1100 0              " put window at right edge of left monitor
    "set lines=85
    "set columns=120
  endif
endif

""""""""""""""""""""""""""""""
" => MRU plugin
""""""""""""""""""""""""""""""
"let MRU_Max_Entries = 400
"map <leader>f :MRU<CR>
