if exists("g:loaded_legend") || !has("signs") || &compatible
  finish
endif
let g:loaded_legend = 1


if !exists("g:legend_active_auto")
  let g:legend_active_auto = 1
endif
if !exists("g:legend_line_hl_auto")
  let g:legend_line_hl_auto = 0
endif
if !exists("g:legend_file_path")
  let g:legend_file_path = ".legend/coverage.vim"
endif

if !exists("g:legend_hit_sign")
  let g:legend_hit_sign     = "✔"
endif
if !exists("g:legend_miss_sign")
  let g:legend_miss_sign    = "✘"
endif
if !exists("g:legend_ignored_sign")
  let g:legend_ignored_sign = "◌"
endif

if !exists("g:legend_hit_color")
  let g:legend_hit_color     = "ctermfg=6    cterm=bold  gui=bold  guifg=Green"
endif
if !exists("g:legend_miss_color")
  let g:legend_miss_color    = "ctermfg=Red  cterm=bold  gui=bold  guifg=Red"
endif
if !exists("g:legend_ignored_color")
  let g:legend_ignored_color = "ctermfg=6    cterm=bold  gui=bold  guifg=Grey"
endif

exec "sign define LegendHit     linehl=HitLine     texthl=HitSign     text=" . g:legend_hit_sign
exec "sign define LegendMiss    linehl=MissLine    texthl=MissSign    text=" . g:legend_miss_sign
exec "sign define LegendIgnored linehl=IgnoredLine texthl=IgnoredSign text=" . g:legend_ignored_sign


let s:coverageFileRelPath = g:legend_file_path

let s:coverageFtimes = {}
let s:allCoverage = {}

function! s:LegendLineHl()
  if !exists("b:legend_line_hl")
    let b:legend_line_hl = g:legend_line_hl_auto
  endif
endfunction

function! s:SetupLineHighlight()
  call s:LegendLineHl()
  if(b:legend_line_hl)
    if exists("g:legend_hit_line_color")
      exec "highlight HitLine     " . g:legend_hit_line_color
    endif
    if exists("g:legend_miss_line_color")
      exec "highlight MissLine    " . g:legend_miss_line_color
    endif
    if exists("g:legend_ignored_line_color")
      exec "highlight IgnoredLine " . g:legend_ignored_line_color
    endif
  else
    highlight clear HitLine
    highlight clear MissLine
    highlight clear IgnoredLine
  endif
endfunction

function! s:SetupHighlight()
  exec "highlight default  HitSign     " . g:legend_hit_color
  exec "highlight default  MissSign    " . g:legend_miss_color
  exec "highlight default  IgnoredSign " . g:legend_ignored_color

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
    call s:SetSign(a:filename, l:line, 'LegendHit')
  endfor

  for line in b:lineCoverage['misses']
    call s:SetSign(a:filename, l:line, 'LegendMiss')
  endfor

  for line in b:lineCoverage['ignored']
    call s:SetSign(a:filename, l:line, 'LegendIgnored')
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

function! s:LegendActive()
  if !exists("b:legend_active")
    let b:legend_active = g:legend_active_auto
  endif
endfunction

function! s:MarkUpBuffer(filepath)
  call s:LegendActive()
  if(!b:legend_active)
    " not active -> not needed
    return
  endif

  call s:ClearCoverageSigns()
  let coverageFile = s:FindCoverageFile(a:filepath)

  if(coverageFile == '')
    echom "No coverage file"
    unlet b:legend_active
    return
  endif

  if(&modified)
    echom "Buffer modified - coverage signs would likely be wrong"
    unlet b:legend_active
    return
  endif

  if(getftime(a:filepath) > getftime(coverageFile))
    echom "Code file is newer that coverage file - signs would likely be wrong"
    unlet b:legend_active
    return
  endif

  call s:LoadFileCoverage(a:filepath, l:coverageFile)

  if(b:legend_active)
    call s:SetCoverageSigns(a:filepath)
  endif
endfunction

function! s:ToggleLegendLine()
  call s:LegendActive()
  call s:LegendLineHl()
  let b:legend_line_hl = !b:legend_line_hl

  call s:SetupLineHighlight()

  if(b:legend_line_hl && !b:legend_active)
    call s:ToggleLegend()
  endif
endfunction

function! s:ToggleLegend()
  call s:LegendActive()
  let b:legend_active = !b:legend_active

  if(b:legend_active)
    call s:MarkUpBuffer(expand("%:p"))
  else
    call s:ClearCoverageSigns()
  endif
endfunction

function! s:EnableLegend()
  let b:legend_active = 1
  call s:MarkUpBuffer(expand("%:p"))
endfunction

function! s:DisableLegend()
  let b:legend_active = 0
  call s:ClearCoverageSigns()
endfunction

command! -nargs=0  Cov             call s:EnableLegend()
command! -nargs=0  Uncov           call s:DisableLegend()
command! -nargs=0  LegendToggle     call s:ToggleLegend()
command! -nargs=0  LegendToggleLine call s:ToggleLegendLine()

if exists("g:legend_mapping_toggle")
  exec "nmap <silent> " . g:legend_mapping_toggle . " :LegendToggle<CR>"
elseif empty(maparg("<Leader>cs", "n"))
  nnoremap <silent> <Leader>cs :LegendToggle<CR>
endif

if exists("g:legend_mapping_toggle_line")
  exec "nmap <silent> " . g:legend_mapping_toggle_line . " :LegendToggleLine<CR>"
elseif empty(maparg("<Leader>lcs", "n"))
  nnoremap <silent> <Leader>lcs :LegendToggleLine<CR>
endif

augroup Legend
  au!
  au  Filetype ruby          call s:SetupHighlight()
  au  BufWinEnter,BufEnter * if &ft=='ruby' | call s:MarkUpBuffer(expand('<afile>:p')) | endif
augroup end
