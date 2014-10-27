if exists("g:loaded_cadre") || !has("signs") || &compatible
  finish
endif
let g:loaded_cadre = 1


if !exists("g:cadre_active_auto")
  let g:cadre_active_auto = 1
endif
if !exists("g:cadre_line_hl_auto")
  let g:cadre_line_hl_auto = 0
endif
if !exists("g:cadre_file_path")
  let g:cadre_file_path = ".cadre/coverage.vim"
endif

if !exists("g:cadre_hit_sign")
  let g:cadre_hit_sign     = "✔"
endif
if !exists("g:cadre_miss_sign")
  let g:cadre_miss_sign    = "✘"
endif
if !exists("g:cadre_ignored_sign")
  let g:cadre_ignored_sign = "◌"
endif

if !exists("g:cadre_hit_color")
  let g:cadre_hit_color     = "ctermfg=6    cterm=bold  gui=bold  guifg=Green"
endif
if !exists("g:cadre_miss_color")
  let g:cadre_miss_color    = "ctermfg=Red  cterm=bold  gui=bold  guifg=Red"
endif
if !exists("g:cadre_ignored_color")
  let g:cadre_ignored_color = "ctermfg=6    cterm=bold  gui=bold  guifg=Grey"
endif

exec "sign define CadreHit     linehl=HitLine     texthl=HitSign     text=" . g:cadre_hit_sign
exec "sign define CadreMiss    linehl=MissLine    texthl=MissSign    text=" . g:cadre_miss_sign
exec "sign define CadreIgnored linehl=IgnoredLine texthl=IgnoredSign text=" . g:cadre_ignored_sign


let s:coverageFileRelPath = g:cadre_file_path

let s:coverageFtimes = {}
let s:allCoverage = {}

function! s:CadreLineHl()
  if !exists("b:cadre_line_hl")
    let b:cadre_line_hl = g:cadre_line_hl_auto
  endif
endfunction

function! s:SetupLineHighlight()
  call s:CadreLineHl()
  if(b:cadre_line_hl)
    if exists("g:cadre_hit_line_color")
      exec "highlight HitLine     " . g:cadre_hit_line_color
    endif
    if exists("g:cadre_miss_line_color")
      exec "highlight MissLine    " . g:cadre_miss_line_color
    endif
    if exists("g:cadre_ignored_line_color")
      exec "highlight IgnoredLine " . g:cadre_ignored_line_color
    endif
  else
    highlight clear HitLine
    highlight clear MissLine
    highlight clear IgnoredLine
  endif
endfunction

function! s:SetupHighlight()
  exec "highlight default  HitSign     " . g:cadre_hit_color
  exec "highlight default  MissSign    " . g:cadre_miss_color
  exec "highlight default  IgnoredSign " . g:cadre_ignored_color

  call s:SetupLineHighlight()
endfunction

function! AddSimplecovResults(file, results)
  let s:allCoverage[fnamemodify(a:file, ":p")] = a:results
endfunction

function! s:LoadAllCoverage(file)
  let l:ftime = getftime(a:file)
  if(!has_key(s:coverageFtimes, a:file) || (s:coverageFtimes[a:file] < l:ftime))
    if(has_key(s:allCoverage, a:file))
      unlet s:allCoverage[a:file]
    endif
    exe "source ".a:file
    let s:coverageFtimes[a:file] = l:ftime
  endif
  let b:coverageFtime = s:coverageFtimes[a:file]
endfunction

function! s:BestCoverage(coverageFile, coverageForName)
  let matchBadness = strlen(a:coverageForName)
  if(has_key(s:allCoverage, a:coverageFile))
    for filename in keys(s:allCoverage[a:coverageFile])
      let matchQuality = match(a:coverageForName, filename . "$")
      if (matchQuality >= 0 && matchQuality < matchBadness)
        let matchBadness = matchQuality
        let found = filename
      endif
    endfor
  endif

  if exists("found")
    let b:lineCoverage = s:allCoverage[a:coverageFile][l:found]
    let b:coverageName = found
  else
    let b:coverageName = '(none)'
    call s:emptyCoverage(a:coverageForName)
  endif
endfunction

function! s:emptyCoverage(coverageForName)
  echom "No coverage recorded for " . a:coverageForName
  let b:lineCoverage = {'hits': [], 'misses': [], 'ignored': [] }
endfunction

function! s:FindCoverageFile(codeFile)
  let found_coverage = findfile(s:coverageFileRelPath,fnamemodify(a:codeFile, ':p:h').";")
  if(found_coverage == '')
    return ''
  else
    return fnamemodify(found_coverage, ":p")
  end
endfunction

function! s:LoadFileCoverage(codeFile, coverageFile)
  call s:LoadAllCoverage(a:coverageFile)
  call s:BestCoverage(a:coverageFile, a:codeFile)
endfunction

function s:SetSign(filename, line, type)
  let id = b:coverageSignIndex
  let b:coverageSignIndex += 1
  let b:coverageSigns += [id]
  exe ":sign place ".id." line=".a:line." name=".a:type." file=" . a:filename
endfunction

"XXX locating buffer + codeFile...
function! s:SetCoverageSigns(filename)
  if (! exists("b:coverageSigns"))
    let b:coverageSigns = []
  endif

  if (! exists("b:coverageSignIndex"))
    let b:coverageSignIndex = 1
  endif

  for line in b:lineCoverage['hits']
    call s:SetSign(a:filename, l:line, 'CadreHit')
  endfor

  for line in b:lineCoverage['misses']
    call s:SetSign(a:filename, l:line, 'CadreMiss')
  endfor

  for line in b:lineCoverage['ignored']
    call s:SetSign(a:filename, l:line, 'CadreIgnored')
  endfor
endfunction

function! s:ClearCoverageSigns()
  if(exists("b:coverageSigns"))
    for signId in b:coverageSigns
      exe ":sign unplace ".signId
    endfor
    unlet! b:coverageSigns
  endif
endfunction

function! s:CadreActive()
  if !exists("b:cadre_active")
    let b:cadre_active = g:cadre_active_auto
  endif
endfunction

function! s:MarkUpBuffer(filepath)
  call s:CadreActive()
  if(!b:cadre_active)
    " not active -> not needed
    return
  endif

  call s:ClearCoverageSigns()
  let coverageFile = s:FindCoverageFile(a:filepath)

  if(coverageFile == '')
    echom "No coverage file"
    unlet b:cadre_active
    return
  endif

  if(&modified)
    echom "Buffer modified - coverage signs would likely be wrong"
    unlet b:cadre_active
    return
  endif

  if(getftime(a:filepath) > getftime(coverageFile))
    echom "Code file is newer that coverage file - signs would likely be wrong"
    unlet b:cadre_active
    return
  endif

  call s:LoadFileCoverage(a:filepath, l:coverageFile)

  if(b:cadre_active)
    call s:SetCoverageSigns(a:filepath)
  endif
endfunction

function! s:ToggleCadreLine()
  call s:CadreActive()
  call s:CadreLineHl()
  let b:cadre_line_hl = !b:cadre_line_hl

  call s:SetupLineHighlight()

  if(b:cadre_line_hl && !b:cadre_active)
    call s:ToggleCadre()
  endif
endfunction

function! s:ToggleCadre()
  call s:CadreActive()
  let b:cadre_active = !b:cadre_active

  if(b:cadre_active)
    call s:MarkUpBuffer(expand("%:p"))
  else
    call s:ClearCoverageSigns()
  endif
endfunction

function! s:EnableCadre()
  let b:cadre_active = 1
  call s:MarkUpBuffer(expand("%:p"))
endfunction

function! s:DisableCadre()
  let b:cadre_active = 0
  call s:ClearCoverageSigns()
endfunction

command! -nargs=0  Cov             call s:EnableCadre()
command! -nargs=0  Uncov           call s:DisableCadre()
command! -nargs=0  CadreToggle     call s:ToggleCadre()
command! -nargs=0  CadreToggleLine call s:ToggleCadreLine()

if exists("g:cadre_mapping_toggle")
  exec "nmap <silent> " . g:cadre_mapping_toggle . " :CadreToggle<CR>"
elseif empty(maparg("<Leader>cs", "n"))
  nnoremap <silent> <Leader>cs :CadreToggle<CR>
endif

if exists("g:cadre_mapping_toggle_line")
  exec "nmap <silent> " . g:cadre_mapping_toggle_line . " :CadreToggleLine<CR>"
elseif empty(maparg("<Leader>lcs", "n"))
  nnoremap <silent> <Leader>lcs :CadreToggleLine<CR>
endif

augroup Cadre
  au!
  au  Filetype ruby          call s:SetupHighlight()
  au  BufWinEnter,BufEnter * if &ft=='ruby' | call s:MarkUpBuffer(expand('<afile>:p')) | endif
augroup end
