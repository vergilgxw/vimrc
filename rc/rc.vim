" vimrc by Guo Xiawei
"

"basic setting {{{
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin
"set mouse=a

" comment this, because this would not work in new version for vimdiff
"set diffexpr=MyDiff()
"function MyDiff()
  "let opt = '-a --binary '
  "if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  "if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  "let arg1 = v:fname_in
  "if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  "let arg2 = v:fname_new
  "if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  "let arg3 = v:fname_out
  "if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  "let eq = ''
  "if $VIMRUNTIME =~ ' '
    "if &sh =~ '\<cmd'
      "let cmd = '""' . $VIMRUNTIME . '\diff"'
      "let eq = '"'
    "else
      "let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    "endif
  "else
    "let cmd = $VIMRUNTIME . '\diff'
  "endif
  "silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
"endfunction

" }}}
" "===================================================="
" space & tab {{{
set shiftwidth=4
"set tabstop=4
set smarttab
"set expandtab
set softtabstop=4
" }}}
" "===================================================="
" full screen (only used in gvim) {{{
"map <F11> <Esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
" }}}
" "===================================================="
" language {{{

if has("multi_byte") 
    " UTF-8 ±àÂë 
    set encoding=utf-8 
    set termencoding=utf-8 
    set formatoptions+=mM 
    set fencs=utf-8,gbk 
    if v:lang =~? '^/(zh/)/|/(ja/)/|/(ko/)' 
        set ambiwidth=double 
    endif 
    if has("win32") 
        source $VIMRUNTIME/delmenu.vim 
        source $VIMRUNTIME/menu.vim 
        language messages zh_CN.utf-8 
    endif 
else 
    echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte" 
endif
" }}}
" "===================================================="
" gui cursor (for cygwin only) {{{
if has("win32unix")
    let &t_ti.="\e[1 q"
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    let &t_te.="\e[0 q"
elseif has("unix")
    let s:uname = system("uname")
    if s:uname == "Darwin\n"
        if exists('$TMUX')
            let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
            let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
            let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
        else
            let &t_SI = "\<Esc>]50;CursorShape=1\x7"
            let &t_SR = "\<Esc>]50;CursorShape=2\x7"
            let &t_EI = "\<Esc>]50;CursorShape=0\x7"
        endif
    endif 
endif

"}}}
" "===================================================="
" Plugin manage (vim-plug){{{
filetype on
filetype plugin on
filetype indent on

call plug#begin('~/.vim/plugged')
"call plug#begin('/usr/share/vim/vim74/plugged')

" Make sure you use single quotes
Plug 'junegunn/seoul256.vim'
Plug 'junegunn/vim-easy-align'

" Group dependencies, vim-snippets depends on ultisnips
"Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
"Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using git URL
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Plugin options
"Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }

" Unmanaged plugin (manually installed and updated)
"Plug '~/my-prototype-plugin'
"Plug 'Lokaltog/vim-powerline'
Plug 'kien/ctrlp.vim'
Plug 'bling/vim-airline'
Plug 'scrooloose/nerdcommenter'
"Plug
Plug 'morhetz/gruvbox'
Plug 'scrooloose/syntastic'
"Plug 'Valloric/YoucompleteMe'
Plug 'Shougo/neocomplcache.vim'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'Latex-Box-Team/Latex-Box'
Plug 'tpope/vim-surround'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'altercation/vim-colors-solarized'
call plug#end()
" }}}
" "===================================================="
" Editor {{{

" line number 
set number
set numberwidth=3
" syntax
syntax enable
syntax on
" ruler
set ruler
set rulerformat=%=%h%m%r%w\ %(%c%V%),%l/%L\ %P
" current mode in status line
set showmode
" display the number of (characters|lines) in visual mode, also cur command
set showcmd  
" always show tab line
set showtabline=2
" cursorline
"set cursorline
" statusline
set laststatus=2
"set statusline=%f\ %2*%m\ %1*%h%r%=[%{&encoding}\ %{&fileformat}\ %{strlen(&ft)?&ft:'none'}\ %{getfperm(@%)}]\ 0x%B\ %12.(%c:%l/%L%)
"set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" }}}
" "===================================================="
" color {{{
"let g:gruvbox_contrast_dark='soft'
" Enable italic 
let g:gruvbox_italic=1

if has("win32")
    let g:rehash256=1
else
    if has("unix")
	" following is for gnome terminal
	if $COLORTERM == 'gnome-terminal'
	    " set 256 color mode (or the colors crash)
	    set t_Co=256
	    let g:rehash256=1
	    " add them to italic line to get gnome-terminal italic support
	    " if not, the italic lines will be very strange background color
	    " the character  should be added by typing ctrl+v+esc (disable win mode
	    " to avoid ctrl+v paste) 
	    set t_ZH=[3m
	    "set t_ZH="\e[[3m"
	    "set t_ZR="\e[[23m"
	    set t_ZR=[23m
	    "highlight Comment cterm=italic
	endif
    endif
endif
set background=dark
colorscheme solarized 
" }}}
" "===================================================="
" general key mapping  and shor command{{{
nnoremap <F6> :tabp<CR>
nnoremap <F7> :tabn<CR>
"command
"command NT NERDTree
nnoremap <c-n> :NERDTreeToggle<CR>
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDCommentEmptyLines = 1
let g:NERDDefaultAlign = 'left'

" }}}
" "===================================================="
"syntastic {{{
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
"let g:syntastic_tex_checkers=[]
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'

let g:statline_syntastic = 0
"set cygwin path
"if has("win32")
if has("win32unix")
    "let g:cygwin_path = 'D:\cygwin64'
    let g:sytastic_python_python = '/bin/python'
endif
" }}}
" "===================================================="
"neocomplache {{{
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 2
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
 
"let g:neocomplcache_enable_auto_select = 1

" Enable heavy features.
" Use camel case completion.
"let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
"let g:neocomplcache_enable_underbar_completion = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions',
    \ 'tex' : $HOME.'/.vim/dictionary/tex_dict'
        \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplcache#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
"inoremap <expr><C-y>  neocomplcache#close_popup()
"inoremap <expr><CR>  pumvisible() ? "\<C-R>=neocomplcache#close_popup()\<CR>" : "\<CR>"
"inoremap <expr><TAB>  pumvisible() ? "\<C-R>=neocomplcache#_close_popup()\<CR>" : "\<TAB>"
inoremap <expr><C-e>  neocomplcache#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? neocomplcache#close_popup() : "\<Space>"

" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left>  neocomplcache#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplcache#close_popup() . "\<Right>"
"inoremap <expr><Up>    neocomplcache#close_popup() . "\<Up>"
"inoremap <expr><Down>  neocomplcache#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplcache_enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplcache_enable_insert_char_pre = 1

" AutoComplPop like behavior.
"let g:neocomplcache_enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplcache_enable_auto_select = 1
"let g:neocomplcache_disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_force_omni_patterns')
  let g:neocomplcache_force_omni_patterns = {}
endif
let g:neocomplcache_force_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_force_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplcache_force_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
" }}}
" "===================================================="
" neosnippet {{{
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<TAB>" : "\<Plug>(neosnippet_expand_or_jump)"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
"if has('conceal')
  "set conceallevel=2 concealcursor=niv
"endif
"let g:tex_conceal = ""
" }}}
" "===================================================="
" latex (including Latex-box) {{{
set shellslash
set grepprg=grep\ -nH\ $* 
let g:tex_flavor='latex'

if has("win32")
    function! s:AltEscape( ) 
	let c='a'
	while c <= 'z'
	    exec "set <A-".c.">=\e".c
	    exec "imap \e".c." <A-".c.">"
	    let c = nr2char(1+char2nr(c))
	endw
	set timeout ttimeoutlen=50    
    endfunction
endif

autocmd Filetype tex set spell |  nnoremap j gj| nnoremap k gk| set colorcolumn=79
autocmd Filetype tex source ~/.vim/rc/myauctex.vim
autocmd Filetype py set colorcolumn=79
"latex box 

let g:LatexBox_viewer = "SumatraPDF -reuse-instance"
"let g:LatexBox_options = pdf
let g:LatexBox_quickfix = 2
"let g:LatexBox_latexmk_async = 1
let g:LatexBox_latexmk_preview_continuously = 1
let g:LatexBox_latexmk_options = "-view=none" 
let g:LatexBox_build_dir = "."
let g:LatexBox_Folding = 0
"try to speed up latex
au FileType tex setlocal nocursorline
au FileType tex :NoMatchParen
" }}}
" "===================================================="
"ctags {{{
set tags=tags;
set autochdir
" }}}
" "===================================================="
"some setting about c/c++ {{{
syn match cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2 
syn match cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1 
hi cFunction gui=NONE guifg=#B5A1FF
" }}}
" "===================================================="
" easy-aline {{{
vmap <CR> <Plug>(EasyAlign)
" }}}
" "===================================================="
" indent-guides {{{
"hi IndentGuidesOdd ctermbg=black
"hi IndentGuidesEven ctermbg=darkgrey
" }}}
" "===================================================="
" python setting {{{
set expandtab
autocmd Filetype python set expandtab 
" quickly execute current python file
autocmd FileType python nnoremap <F4> :execute "w" <enter> :execute "!ipython %" <enter>
" }}}
" "===================================================="
" ctrlp {{{
let g:ctrlp_map = '<c-p>'
"let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_working_path_mode = 'ra'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }
" }}}
" "===================================================="
"autocmd FileType csv 
nmap <leader>aa :set wrap! \| :%!column -t -s,<CR>
"  vim: fdm=marker
