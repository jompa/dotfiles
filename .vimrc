"Lots stolen from:
"https://github.com/alexreisner/dotfiles/blob/master/.vimrc
"https://github.com/mkotsalainen/dotvim/blob/master/vimrc

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs

" Reload vimrc on save
autocmd! bufwritepost .vimrc source %

" ---------------------------------------------------------------------------
"  Pathogen (must be set up before filetype detection)
" ---------------------------------------------------------------------------

" system's .vimrc calls filetype; turn it off here to force reload
filetype on " turn on to avoid non-zero exit code on OSX
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

set history=700

" Disable backupfiles
set nobackup
set nowritebackup
set noswapfile

" Rebind <Leader> key
let mapleader = "," 

" Fast saving
nmap <leader>w :w!<cr>

" ----------------------------------------------------------------------------
"  Mappings
" ----------------------------------------------------------------------------

" Map space to / (search) and c-space to ? (backgwards search)
map <space> /
map - /
map <c-space> ?
"  exit insert mode
imap jk <esc>

map ö $
map Ö :

" split navigation
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

map <D-j> jjjj
map <D-k> kkkk

map <leader>n :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
map <leader>f :FufFile **/<CR>

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
set wrap "Wrap lines
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
" ----------------------------------------------------------------------------
"  Graphical
" ----------------------------------------------------------------------------

set t_Co=256 " Explicitly tell Vim that the terminal supports 256 colors
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

if has('gui_running')
  colorscheme molokai

  if system("uname") == "Darwin\n" " on OSX
    "set guifont=Monaco:h12
    "set lines=55
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
