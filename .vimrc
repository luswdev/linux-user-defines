call plug#begin()

Plug 'reewr/vim-monokai-phoenix'
Plug 'joshdick/onedark.vim'
Plug 'sheerun/vim-polyglot'
Plug 'NLKNguyen/papercolor-theme'
Plug 'w0ng/vim-hybrid'
Plug 'majutsushi/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'wakatime/vim-wakatime'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()

set background=dark

set mouse=nv
set encoding=utf8
set mouse+=a
set nu
set incsearch
set cursorline

syntax on

highlight CursorLineNR ctermbg=236 ctermfg=yellow cterm=bold 
highlight LineNr ctermfg=grey
highlight Comment ctermbg=00 ctermfg=244

inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap ' ''<Esc>i
inoremap " ""<Esc>i
inoremap {<CR> {<CR>}<Esc>ko

fun! ShowFuncName()
  let lnum = line(".")
  let col = col(".")
  echohl ModeMsg
  echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
  echohl None
  call search("\\%" . lnum . "l" . "\\%" . col . "c")
endfun
map f :call ShowFuncName() <CR>

let g:airline_theme='minimalist'
let g:airline#extensions#hunks#enabled=0
let g:airline#extensions#branch#enabled=1

" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" set list
set list
set listchars=tab:>-,trail:·,nbsp:␣

set lcs+=space:·

set tabstop=4       " Number of spaces that a <Tab> counts for
set shiftwidth=4    " Number of spaces to use for autoindent
set expandtab       " Use spaces instead of tabs

autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0 tabstop=8

let g:fzf_layout = { 'down': '~40%' }

colorscheme PaperColor

