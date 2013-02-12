"   /\_\    ___     ___ ___   _____      __     
"   \/\ \  / __`\ /' __` __`\/\ '__`\  /'__`\   
"    \ \ \/\ \L\ \/\ \/\ \/\ \ \ \L\ \/\ \L\.\_ 
"    _\ \ \ \____/\ \_\ \_\ \_\ \ ,__/\ \__/.\_\
"  /\ \_\ \/___/  \/_/\/_/\/_/\ \ \/  \/__/\/_/
"  \ \____/                    \ \_\           
"  \/___/                      \/_/ 

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

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

"  exit insert mode
imap jk <esc>

" split navigation
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

