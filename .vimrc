" Eagerly stolen from:
"https://github.com/alexreisner/dotfiles/blob/master/.vimrc
"https://github.com/mkotsalainen/dotvim/blob/master/vimrc

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

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
filetype plugin  on  " load filetype plugin
filetype indent  on  " load filetype plugen

set whichwrap+=<,>,h,l

" Set to auto read when a file is changed from the outside
set autoread
" Disable backupfiles
set nobackup
set nowritebackup
set noswapfile

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
inoremap {      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap {{     {
inoremap {}     {}

" Quick navigation
map <C-j> jjjj
map <C-k> kkkk
map <C-l> 0
map <C-h> $

" Ack
map <leader>a <Esc>:Ack!
"set grepprg=ack\ --nogroup\ $*

map <leader><Space> <leader>c<Space>
map <silent> <leader>n :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
" Exclude files
let NERDTreeIgnore = ['\.pyc$']

"Fuzzyfinder
"let g:fuf_file_exclude = '\v\~$|\.o$|\.exe$|\.bak$|\.swp|\.class$'
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
hi CursorLine term=bold cterm=bold guibg=Grey40
hi Cursor guibg=#0087ad
" ----------------------------------------------------------------------------
"  Graphical
" ----------------------------------------------------------------------------

set t_Co=256 " Explicitly tell Vim that the terminal supports 256 colors
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

if has('gui_running')
  "colorscheme molokai
  "colorscheme wombat 
  colorscheme jompa_wombat 

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
