function! Shuffle(list)
    let n = len(a:list)
        for i in range(0, n-2)
            let j = Random(0, n-i-1)
            let e = a:list[i]
            let a:list[i] = a:list[i+j]
            let a:list[i+j] = e
        endfor
    return a:list
endfunction

function! Random(min, max)
    let i = system('echo $RANDOM')
    return i * (a:max - a:min + 1) / 32768 + a:min
endfunction

let s:current_kata = 0
let s:kata_pairs = []
let s:start_katas = '<C-L>'
let s:next_kata_mapping = '<C-K>'
let s:previous_kata_mapping = '<C-J>'
let s:goto_kata_mapping = '<C-G>'
if exists('g:vim_kata_next_kata_mapping')
    let s:next_kata_mapping = g:vim_kata_next_kata_mapping
endif
if exists('g:vim_kata_previous_kata_mapping')
    let s:previous_kata_mapping = g:vim_kata_previous_kata_mapping
endif
if exists('g:vim_kata_goto_kata_mapping')
    let s:goto_kata_mapping = g:vim_kata_goto_kata_mapping
endif
execute 'nnoremap <silent> '.s:start_katas.' :<C-U>call KataStart()<CR>'
execute 'nnoremap <silent> '.s:next_kata_mapping.' :<C-U>call KataNext()<CR>'
execute 'nnoremap <silent> '.s:previous_kata_mapping.' :<C-U>call KataPrevious()<CR>'
execute 'nnoremap <silent> '.s:goto_kata_mapping.' :<C-U>call KataGoto()<CR>'
execute 'nnoremap g? :<C-U>call CurrentKataTip()<CR>'

function! CurrentKataTip()
    let current_conf = s:kata_pairs[s:current_kata]
    let tips = ''
    let tips_path = current_conf.tips
    if filereadable(tips_path)
        let tips = join(readfile(tips_path), "\n")
    endif
    echo tips
endfunction

function! LoadKatas()
    let result = []
    let katas_dir = 'katas'
    if exists('g:vim_kata_katas_dir')
        let katas_dir = g:vim_kata_katas_dir
    endif
    let dirs = systemlist('ls '. katas_dir)
    for dir in dirs
        let ext = 'txt'
        let ext_path = katas_dir.'/'.dir.'/ext'
        if filereadable(ext_path)
            let ext = readfile(ext_path)[0]
        endif
        let in = katas_dir.'/'.dir.'/in'
        let out = katas_dir.'/'.dir.'/out'
        let tips = katas_dir.'/'.dir.'/tips'
        call add(result, {'in': in, 'out': out, 'ext': ext, 'dir': dir, 'tips': tips})
    endfor
    if !exists('g:vim_kata_shuffle') || g:vim_kata_shuffle
        call Shuffle(result)
    endif
    let s:kata_pairs = result
endfunction

function! KataNext()
    w!
    if s:current_kata >= len(s:kata_pairs) - 1
        silent echo 'Already at last kata'
        return
    endif
    let s:current_kata += 1
    call LoadCurrentKata()
endfunction

function! KataPrevious()
    w!
    if s:current_kata <= 0
        silent echo 'Already at first kata'
        return
    endif
    let s:current_kata -= 1
    call LoadCurrentKata()
endfunction

function! KataGoto()
    call inputsave()
    let dir = input('Enter kata directory: ')
    call inputrestore()
    let kata_dirs = map(copy(s:kata_pairs), 'v:val.dir')
    let i = index(kata_dirs, dir)
    if i == -1
        redraw
        echo 'Kata directory not found: ' . dir
        return
    endif
    let s:current_kata = i
    call LoadCurrentKata()
endfunction

function! KataStart()
    tabnew
    call LoadCurrentKata()
endfunction

function! LoadCurrentKata()
    let diff_on = 1
    if exists('g:vim_kata_diff_on')
        let diff_on = g:vim_kata_diff_on
    endif
    let current_conf = s:kata_pairs[s:current_kata]
    let pair = CreateWorkKata(current_conf)
    let item_in = pair[0]
    let item_out = pair[1]
    if diff_on
        windo diffoff
    endif
    silent only
    execute 'edit '.item_in
    setlocal nolist
    setlocal foldlevel=9999
    " place a literal ^K somewhere in the 'in' document to specify
    " a custom cursor start location
    let line_number = search('\%x0b')
    if line_number
        " remove ^K and clear undo history
        normal! dl
        let old_undolevels = &undolevels
        set undolevels=-1
        execute "normal a \<BS>\<Esc>"
        let &undolevels = old_undolevels
    endif
    let split_command = 'vsplit'
    if exists('g:vim_kata_split_command')
        let split_command = g:vim_kata_split_command
    endif
    execute split_command.' '.item_out
    setlocal foldlevel=9999
    setlocal nolist
    setlocal nomodifiable
    if diff_on
        windo diffthis
    endif
    wincmd t
    normal! ]c
    normal! zR
endfunction

function! CreateWorkKata(conf)
    let file_in_content = readfile(a:conf.in)
    let file_out_content = readfile(a:conf.out)
    let tips = readfile(a:conf.tips)
    let file_in = tempname() . '.' . a:conf.dir . '.in.' . a:conf.ext
    let file_out = tempname() . '.' . a:conf.dir .'.out.' . a:conf.ext
    call writefile(tips + file_in_content, file_in)
    call writefile(tips + file_out_content, file_out)
    return [file_in, file_out]
endfunction

call LoadKatas()
