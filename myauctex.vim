

" Explanation and Customization   {{{

let b:AMSLatex = 0
let b:DoubleDollars = 0
" prefix for the "Greek letter" macros (For personal macros, it is ';')
let mapleader = ';'

" Set b:AMSLatex to 1 if you are using AMSlatex.  Otherwise, the program will 
" attempt to automatically detect the line \usepackage{...amsmath...} 
" (uncommented), which would indicate AMSlatex.  This is mainly for the 
" function keys F1 - F5, which insert the most common environments, and 
" C-F1 - C-F5, which change them.  See "Inserting and Changing Environments"
" for information.
" Set b:DoubleDollars to 1 if you use $$...$$ instead of \[...\]
" With b:DoubleDollars = 1, C-F1 - C-F5 will not work in nested environments.

" Auctex-style macros for Latex typing.
" You will have to customize the functions RunLatex(), Xdvi(), 
" and the maps for inserting template files, on lines 168 - 169

" Thanks to Peppe Guldberg for important suggestions.
"
" Please read the comments in the file for an explanation of all the features.
" One of the main features is that the "mapleader" (set to "`" see above),
" triggers a number of macros (see "Embrace the visual region" and 
" "Greek letters".  For example, `a would result in \alpha.  
" There are many other features;  read the file.
"
" The following templates are inserted with <F1> - <F4>, in normal mode.
" The first 2 are for latex documents, which have "\title{}"
let b:template_1 = '~/.Vim/latex'
let b:template_2 = '~/.Vim/min-latex'
" The next template is for a letter, which has "\opening{}"
let b:template_3 = '~/.Vim/letter'
" The next template is for a miscellaneous document.
let b:template_4 = '~/Storage/Latex/exam.tex'

" The following is necessary for TexFormatLine() and TexFill()
set tw=0
" substitute text width
let b:tw = 79

" If you are using Windows, modify b:latex_command above, and set 
" b:windows below equal to 1
let b:windows = 0

" }}}
" "====================================================================="
" Typing .. results in \ldots or \cdots   {{{

" Use this if you want . to result in a just a period, with no spaces.
"function! s:Dots(var)
"    let column = col('.')
"    let currentline = getline('.')
"    let left = strpart(currentline ,column-3,2)
"    let before = currentline[column-4]
"    if left == '..'
"    	if a:var == 0
"	    if before == ','
"		return "\<BS>\<BS>\\ldots"
"	    else
"		return "\<BS>\<BS>\\cdots"
"	    endif
"        else
"	    return "\<BS>\<BS>\\dots"
"	endif
"    else
"       return '.'
"    endif
"endfunction
" Use this if you want . to result in a period followed by 2 spaces.
" To get just one space, see the comment in the function below.
function! s:Dots(var)
    let column = col('.')
    let currentline = getline('.')
    let previous = currentline[column-2]
    let before = currentline[column-3]
    if strpart(currentline,column-4,3) == '.  '
	return "\<BS>\<BS>"
    elseif previous == '.'
    	if a:var == 0
	    if before == ','
		return "\<BS>\\ldots"
	    else
		return "\<BS>\\cdots"
	    endif
        else
	    return "\<BS>\\dots"
	endif
    elseif previous =~ '[\$A-Za-z]' && currentline !~ '@'
	" To get just one space, replace '.  ' with '. ' below.
	return <SID>TexFill(b:tw, '.  ')  "TexFill is defined in Auto-split
    else
	return '.'
    endif
endfunction
" Uncomment the next line, and comment out the line after,
" if you want the script to decide between latex and amslatex.
" This slows down the macro.
"inoremap <buffer><silent> . <C-R>=<SID>Dots(<SID>AmsLatex(b:AMSLatex))<CR>
inoremap <buffer><silent> . <Space><BS><C-R>=<SID>Dots(b:AMSLatex)<CR>
" Note: <Space><BS> makes word completion work correctly.

" }}}
" "====================================================================="
" Auto-split long lines.   {{{

" Key Bindings                {{{

noremap <buffer> gq :call <SID>TexFormatLine(b:tw,getline('.'),col('.'))<CR>
noremap <buffer> Q :call <SID>TexFormatLine(b:tw,getline('.'),col('.'))<CR>
vnoremap <buffer> Q J:call <SID>TexFormatLine(b:tw,getline('.'),col('.'))<CR>
"  With this map, <Space> will split up a long line, keeping the dollar
"  signs together (see the next function, TexFormatLine).
inoremap <buffer><silent> <Space> <Space><BS><C-R>=<SID>TexFill(b:tw, ' ')<CR>
" Note: <Space><BS> makes word completion work correctly.

" }}}

" Functions       {{{

function! s:TexFill(width, string)
    if col('.') > a:width
	" For future use, record the current line and 
	" the number of the current column.
	let current_line = getline('.')
	let current_column = col('.')
	execute 'normal! i'.a:string.'##'
	call <SID>TexFormatLine(a:width,current_line,current_column)
	call search('##', 'b')
	return "\<Del>\<Del>"
    else
	return a:string
    endif
endfunction

function! s:TexFormatLine(width,current_line,current_column)
    " Find the first nonwhitespace character.
    let first = matchstr(a:current_line, '\S')
    normal! $
    let length = col('.')
    let go = 1
    while length > a:width+2 && go
	let between = 0
	let string = strpart(getline('.'),0,a:width)
	" Count the dollar signs
        let number_of_dollars = 0
	let evendollars = 1
	let counter = 0
	while counter <= a:width-1
	    " Pay attention to '$$'.
	    "if string[counter] == '$' && string[counter-1] != '$'
	    if string[counter] == '$' && string[counter-1] !~ '\$\|\\'
	       let evendollars = 1 - evendollars
	       let number_of_dollars = number_of_dollars + 1
	    endif
	    let counter = counter + 1
	endwhile
	" Get ready to split the line.
	execute 'normal! ' . (a:width + 1) . '|'
	if evendollars
	" Then you are not between dollars.
	    call search("\\$\\+\\| ", 'b')
	    normal W
	else
	" Then you are between dollars.
	    normal! F$
	    " Move backward once more if you are at "$$".
	    if getline('.')[col('.')-2] == '$'
		normal h
	    endif
	    if col('.') == 1 || strpart(getline('.'),col('.')-1,1) != '$'
	       let go = 0
	    endif
	endif
	if first == '$' && number_of_dollars == 1
	    let go = 0
	else
	    execute "normal! i\<CR>\<Esc>$"
	    " Find the first nonwhitespace character.
	    let first = matchstr(getline('.'), '\S')
	endif
	let length = col('.')
    endwhile
    if go == 0 && strpart(a:current_line,0,a:current_column) =~ '.*\$.\+\$.*'
	execute "normal! ^f$a\<CR>\<Esc>"
	call <SID>TexFormatLine(a:width,a:current_line,a:current_column)
    endif
endfunction

" }}}

" }}}
" "====================================================================="
" _{} and ^{}   {{{

" Typing __ results in _{}
function! s:SubBracket()
    let insert = '_'
    let left = getline('.')[col('.')-2]
    if left == '_'
	let insert = "{}\<Left>"
    endif
    return insert
endfunction
inoremap <buffer><silent> _ <C-R>=<SID>SubBracket()<CR>

" Typing ^^ results in ^{}
function! s:SuperBracket()
    let insert = '^'
    let left = getline('.')[col('.')-2]
    if left == '^'
	let insert = "{}\<Left>"
    endif
    return insert
endfunction
inoremap <buffer><silent> ^ <C-R>=<SID>SuperBracket()<CR>

" }}}
" "====================================================================="
" Alt-l or Insert-l inserts \left...\right (3 alternatives)   {{{

" In the first version, you type Alt-l and then the bracket
" In the second version, you type the bracket, and then Alt-l
" It also doubles as a command for inserting \label{}, if the previous
" character is blank.
" The third version is like the second version.  Use it if you have
" disabled automatic bracket completion.
"inoremap <buffer> <M-l>( \left(\right)<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l( \left(\right)<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>\| \left\|\right\|<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l\| \left\|\right\|<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>[ \left[\right]<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l[ \left[\right]<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>{ \left\{\right\}<Left><Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l{ \left\{\right\}<Left><Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>< \langle\rangle<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <Insert>l< \langle\rangle<Left><Left><Left><Left><Left><Left><Left>
"inoremap <buffer> <M-l>q \lefteqn{
"inoremap <buffer> <Insert>lq \lefteqn{
function! s:LeftRight()
    let line = getline('.')
    let char = line[col('.')-1]
    let previous = line[col('.')-2]
    if char =~ '(\|\['
        execute "normal! i\\left\<Esc>la\\right\<Esc>6h"
    elseif char == '|'
	if previous == '\'
	    execute "normal! ileft\\\<Esc>"
	else
	    execute "normal! i\\left\<Esc>"
	endif
	execute "normal! la\\right\<Esc>6h"
    elseif char == '{'
	if previous == '\'
	    execute "normal! ileft\\\<Esc>la\\right\<Esc>6h"
	else
	    execute "normal! i\\left\\\<Esc>la\\right\\\<Esc>7h"
	endif
    elseif char == '<'
	execute "normal! s\\langle\\rangle\<Esc>7h"
    elseif char == 'q'
	execute "normal! s\\lefteqn\<C-V>{\<Esc>"
    else
	execute "normal! a\\label\<C-V>{}\<Esc>h"
    endif

endfunction

" Put \left...\right in front of the matched brackets.
function! s:PutLeftRight()
    let previous = getline('.')[col('.') - 2]
    let char = getline('.')[col('.') - 1]
    if previous == '\'
    if char == '{'
	execute "normal! ileft\\\<Esc>l%iright\\\<Esc>l%"
    elseif char == '}'
	execute "normal! iright\\\<Esc>l%ileft\\\<Esc>l%"
    endif
    elseif char =~ '\[\|('
	execute "normal! i\\left\<Esc>l%i\\right\<Esc>l%"
    elseif char =~ '\]\|)'
	execute "normal! i\\right\<Esc>l%i\\left\<Esc>l%"
    endif
endfunction
inoremap <buffer> <M-l> <Esc>:call <SID>LeftRight()<CR>a
inoremap <buffer> <Insert>l <Esc>:call <SID>LeftRight()<CR>a
noremap <buffer> <M-l> :call <SID>PutLeftRight()<CR>
noremap <buffer> <Insert>l :call <SID>PutLeftRight()<CR>
vnoremap <buffer> <M-l> <C-C>`>a\right<Esc>`<i\left<Esc>
vnoremap <buffer> <Insert>l <C-C>`>a\right<Esc>`<i\left<Esc>
"function! s:LeftRight()
"let char = getline('.')[col('.')-1]
"let previous = getline('.')[col('.')-2]
"if char == '('
"	execute "normal! i\\left\<Esc>la\\right)\<Esc>7h"
"elseif char == '['
"	execute "normal! i\\left\<Esc>la\\right]\<Esc>7h"
"elseif char == '|'
"	if previous == '\'
"		execute "normal! ileft\\\<Esc>la\\right\\\|\<Esc>8h"
"	else
"		execute "normal! i\\left\<Esc>la\\right\|\<Esc>7h"
"	endif
"elseif char == '{'
"	if previous == '\'
"		execute "normal! ileft\\\<Esc>la\\right\\}\<Esc>8h"
"	else
"		execute "normal! i\\left\\\<Esc>la\\right\\}\<Esc>8h"
"	endif
"elseif char == '<'
"	execute "normal! s\\langle\\rangle\<Esc>7h"
"elseif char == 'q'
"	execute "normal! s\\lefteqn{\<Esc>lx"
"endif
"endfunction

" }}}
" "====================================================================="
" Smart quotes.   {{{
" Thanks to Ron Aaron <ron@mossbayeng.com>.
function! s:TexQuotes()
    let insert = "''"
    let left = getline('.')[col('.')-2]
    if left =~ '^\(\|\s\)$'
	let insert = '``'
    elseif left == '\'
	let insert = '"'
    endif
    return insert
endfunction
inoremap <buffer> " <C-R>=<SID>TexQuotes()<CR>

" }}}
" "====================================================================="
" Bracket Completion Macros   {{{

" Key Bindings                {{{

" Typing the symbol a second time (for example, $$) will result in one
" of the symbole (for instance, $).  With {, typing \{ will result in \{\}.
inoremap <buffer><silent> ( <C-R>=<SID>Double('(',')')<CR>
"inoremap <buffer><silent> [ <C-R>=<SID>Double('[',']')<CR>
inoremap <buffer><silent> [ <C-R>=<SID>CompleteSlash('[',']')<CR>
inoremap <buffer><silent> $ <C-R>=<SID>Double('$','$')<CR>
inoremap <buffer><silent> & <C-R>=<SID>DoubleAmpersands()<CR>
inoremap <buffer><silent> { <C-R>=<SID>CompleteSlash('{','}')<CR>
inoremap <buffer><silent> \| <C-R>=<SID>CompleteSlash("\|","\|")<CR>

" If you would rather insert $$ individually, the following macro by 
" Charles Campbell will make the cursor blink on the previous dollar sign,
" if it is in the same line.
" inoremap <buffer> $ $<C-O>F$<C-O>:redraw!<CR><C-O>:sleep 500m<CR><C-O>f$<Right>

" }}}

" Functions         {{{

" For () and $$
function! s:Double(left,right)
    if strpart(getline('.'),col('.')-2,2) == a:left . a:right
	return "\<Del>"
    else
	return a:left . a:right . "\<Left>"
    endif
endfunction

" Complete [, \[, {, \{, |, \|
function! s:CompleteSlash(left,right)
    let column = col('.')
    let first = getline('.')[column-2]
    let second = getline('.')[column-1]
    if first == "\\"
	if a:left == '['
	    return "\[\<CR>\<CR>\\]\<Up>"
	else
	    return a:left . "\\" . a:right . "\<Left>\<Left>"
	endif
    else
	if a:left =~ '\[\|{'
	\ && strpart(getline('.'),col('.')-2,2) == a:left . a:right
	    return "\<Del>"
        else
            return a:left . a:right . "\<Left>"
	endif
    endif
endfunction

" Double ampersands, if you are in an eqnarray or eqnarray* environment.
function! s:DoubleAmpersands()
    let stop = 0
    let currentline = line('.')
    while stop == 0
	let currentline = currentline - 1
	let thisline = getline(currentline)
	if thisline =~ '\\begin' || currentline == 0
	    let stop = 1
	endif
    endwhile
    if thisline =~ '\\begin{eqnarray\**}'
	return "&&\<Left>"
    elseif strpart(getline('.'),col('.')-2,2) == '&&'
	return "\<Del>"
    else
	return '&'
    endif
endfunction

" }}}

" }}}
" "====================================================================="
" Tab key mapping   {{{
" In a math environment, the tab key moves between {...} braces, or to the end
" of the line or the end of the environment.  Otherwise, it does word
" completion.  But if the previous character is a blank, or if you are at the
" end of the line, you get a tab.  If the previous characters are \ref{
" then a list of \label{...} completions are displayed.  Choose one by
" clicking on it and pressing Enter.  q quits the display.  Ditto for 
" \cite{, except you get to choose from either the bibitem entries, if any,
" or the bibtex file entries.
" This was inspired by the emacs package Reftex.
"inoremap <buffer><silent> <Tab> pumvisible() ? "\<C-n>" : "\<C-R>=\<SID>TexInsertTabWrapper('backward')\<CR>"
"inoremap <buffer><silent> <expr><Tab> pumvisible() ? "\<C-n>" : "\<C-R>=\<SID>TexInsertTabWrapper('backward')\<CR>"

"unmap <TAB>
"inoremap <buffer><silent> <expr><Tab> pumvisible() ? "\<C-R>=neocomplcache#close_popup()\<CR>" : "\<C-R>=\<SID>TexInsertTabWrapper('backward')\<CR>"
let g:BASH_Ctrl_j = 'off'
inoremap <buffer><silent> <expr><C-j> pumvisible() ?
	    \ "\<C-R>=neocomplcache#close_popup()\<CR>\<C-R>=\<SID>TexInsertTabWrapper('backward')\<CR>" 
	    \ : "\<C-R>=\<SID>TexInsertTabWrapper('backward')\<CR>"
"inoremap <buffer><silent> <Tab> <C-R>=<SID>TexInsertTabWrapper('backward')<CR>

function! s:TexInsertTabWrapper(direction) 

    " Check to see if you're in a math environment.  Doesn't work for $$...$$.
    let line = getline('.')
    let len = strlen(line)
    let column = col('.') - 1
    let ending = strpart(line, column, len)
    let n = 0

    let dollar = 0
    while n < strlen(ending)
	if ending[n] == '$'
	    let dollar = 1 - dollar
	endif
	let n = n + 1
    endwhile

    let math = 0
    let ln = line('.')
    while ln > 1 && getline(ln) !~ '\\begin\|\\end\|\\\]\|\\\['
	let ln = ln - 1
    endwhile
    if getline(ln) =~ 'begin{\(eq\|arr\|align\|mult\)\|\\\['
	let math = 1
    endif

    " Check to see if you're between brackets in \ref{} or \cite{}.
    " Inspired by RefTex.
    " Typing q returns you to editing
    " Typing <CR> or Left-clicking takes the data into \ref{} or \cite{}.
    " Within \cite{}, you can enter a regular expression followed by <Tab>,
    " Only the citations with matching authors are shown.
    " \cite{c.*mo<Tab>} will show articles by Mueller and Moolinar, for example.
    " Once the citation is shown, you type <CR> anywhere within the citation.
    " The bibtex files listed in \bibliography{} are the ones shown.
    if strpart(line,column-5,5) == '\ref{'
	let name = bufname(1)
	let short = substitute(name, ".*/", "", "")
	let aux = strpart(short, 0, strlen(short)-3)."aux"
	if filereadable(aux)
	    let tmp = tempname()
	    execute "below split ".tmp
	    execute "0read ".aux
	    g!/^\\newlabel{/delete
	    g/^\\newlabel{tocindent/delete
	    g/./normal 3f{lyt}0Pf}D0f\cf{       
	    execute "write! ".tmp

	    noremap <buffer> <LeftRelease> <LeftRelease>:call <SID>RefInsertion("aux")<CR>zza
	    noremap <buffer> <CR> :call <SID>RefInsertion("aux")<CR>zza
	    noremap <buffer> q :bwipeout!<CR>zzi
	    return "\<Esc>"
	else
	    let tmp = tempname()
	    vertical 15split
	    execute "write! ".tmp
	    execute "edit ".tmp
	    g!/\\label{/delete
	    %s/.*\\label{//e
	    %s/}.*//e
	    noremap <buffer> <LeftRelease> <LeftRelease>:call <SID>RefInsertion(0)<CR>zza
	    noremap <buffer> <CR> :call <SID>RefInsertion(0)<CR>zza
	    noremap <buffer> q :bwipeout!<CR>zzi
	    return "\<Esc>"
	endif
    elseif strpart(line,column-6,6) == '\cite{'
	let tmp = tempname()
        execute "write! ".tmp
        execute "split ".tmp

	if 0 != search('\\begin{thebibliography}')
	    bwipeout!
	    execute "below split ".tmp
	    call search('\\begin{thebibliography}')
	    normal kdgg
	    noremap <buffer> <LeftRelease> <LeftRelease>:call <SID>CiteInsertion('\\bibitem')<CR>zza
	    vnoremap <buffer> <RightRelease> <C-c><Left>:call <SID>CommaCiteInsertion('\\bibitem')<CR>
	    noremap <buffer> <CR> :call <SID>CiteInsertion('\\bibitem')<CR>zza
	    noremap <buffer> , :call <SID>CommaCiteInsertion('\\bibitem')<CR>
	    noremap <buffer> q :bwipeout!<CR>f}zzi
	    return "\<Esc>"
	else
	    let l = search('\\bibliography{')
	    bwipeout!
	    if l == 0
		return ''
	    else
		let s = getline(l)
		let beginning = matchend(s, '\\bibliography{')
		let ending = matchend(s, '}', beginning)
		let f = strpart(s, beginning, ending-beginning-1)
		let tmp = tempname()
		execute "below split ".tmp
		let file_exists = 0

		let name = bufname(1)
		let base = substitute(name, "[^/]*$", "", "")
		while f != ''
		    let comma = match(f, ',[^,]*$')
		    if comma == -1
			let file = base.f.'.bib'
			if filereadable(file)
			    let file_exists = 1
			    execute "0r ".file
			endif
			let f = ''
		    else
			let file = strpart(f, comma+1)
			let file = base.file.'.bib'
			if filereadable(file)
			    let file_exists = 1
			    execute "0r ".file
			endif
			let f = strpart(f, 0, comma)
		    endif
		endwhile

		noremap <buffer> <LeftRelease> <LeftRelease>:call <SID>CiteInsertion("@")<CR>zza
		vnoremap <buffer> <RightRelease> <C-c><Left>:call <SID>CommaCiteInsertion("@")<CR>
		noremap <buffer> <CR> :call <SID>CiteInsertion("@")<CR>zza
		noremap <buffer> , :call <SID>CommaCiteInsertion("@")<CR>
		noremap <buffer> q :bwipeout!<CR>zzi
		return "\<Esc>"

	    endif
	endif
    elseif dollar == 1   " If you're in a $..$ environment
	if ending[0] =~ ')\|]\||'
	    return "\<Right>"
	elseif ending =~ '^\\}\|\\|'
	    return "\<Right>\<Right>"
	elseif ending =~ '^\\right\\'
	    return "\<Esc>8la"
	elseif ending =~ '^\\right'
	    return "\<Esc>7la"
	elseif ending =~ '^}\(\^\|_\|\){'
	    return "\<Esc>f{a"
	elseif ending[0] == '}'
	    return "\<Right>"
	else
	    return "\<Esc>f$a"
	end
	"return "\<Esc>f$a"
    elseif math == 1    " If you're in a regular math environment.
	if ending =~ '^\s*&'
	    return "\<Esc>f&a"
        elseif ending[0] =~ ')\|]\||'
	    return "\<Right>"
	elseif ending =~ '^\\}\|\\|'
	    return "\<Right>\<Right>"
	elseif ending =~ '^\\right\\'
	    return "\<Esc>8la"
	elseif ending =~ '^\\right'
	    return "\<Esc>7la"
	elseif ending =~ '^}\(\^\|_\|\){'
	    return "\<Esc>f{a"
	elseif ending[0] == '}'
	    if line =~ '\\label'
		return "\<Down>"
	    else
		return "\<Esc>f}a"
	    endif
	elseif column == len    "You are at the end of the line.
	    call search("\\\\end\\|\\\\]")
	    return "\<Esc>o"
	else
	    return "\<C-O>$"
	endif
    else   " If you're not in a math environment.
	" Thanks to Benoit Cerrina (modified)
	if ending[0] =~ ')\|}'  " Go past right parentheses.
	    return "\<Right>"
	elseif !column || line[column - 1] !~ '\k' 
	    return "\<Tab>" 
	elseif a:direction == 'backward'
	    return "\<C-P>" 
	else 
	    return "\<C-N>" 
	endif 

    endif
endfunction 

" Inspired by RefTex
function! s:RefInsertion(x)
    if a:x == "aux"
	normal 0Wy$
    else
	normal 0y$
    endif
    bwipeout!
    let thisline = getline('.')
    let thiscol  = col('.')
    if thisline[thiscol-1] == '{'
	normal p
    else
	normal P
	if thisline[thiscol-1] == '}'
	    normal l
	    if thisline[thiscol] == ')'
		normal l
	    endif
	endif
    endif
endfunction

" Inspired by RefTex
" Get one citation from the .bib file or from the bibitem entries.
function! s:CiteInsertion(x)
    +
    "if search('@','b') != 0
    if search(a:x, 'b') != 0
	if a:x == "@"
	    normal f{lyt,
	else
	    normal f{lyt}
	endif
        bwipeout!
	normal Pf}
    else
        bwipeout!
    endif
endfunction

" Inspired by RefTex
" Get one citation from the .bib file or from the bibitem entries
" and be ready to get more.
function! s:CommaCiteInsertion(x)
    +
    if search(a:x, 'b') != 0
	if a:x == "@"
	    normal f{lyt,
	else
	    normal f{lyt}
	endif
	normal Pa,f}
    else
        bwipeout!
    endif
endfunction

" }}}
" vim: fdm=marker

