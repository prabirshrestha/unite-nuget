let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#nuget#define()
    return [s:nuget_search_source]
endfunction

let s:nuget_search_source = {
    \   'name': 'nuget/search',
    \   'description': 'Search nuget.org',
    \   'max_candidates': 100,
    \   'default_kind': 'uri',
    \   'default_action': { 'uri': 'start' },
    \ }

function! unite#sources#nuget#search(query)
    let url = 'https://api-search.nuget.org/search/query'
    let res = webapi#http#get(url, {
                \ 'q': a:query
                \ })

    if res.content == ''
        throw 'Getting nuget search results failed. Please try again.'
    endif

    let content = webapi#json#decode(res.content)
    return content
endfunction

function! s:nuget_search_source.gather_candidates(args, context)
    if empty(a:args)
      let l:word = unite#util#input("Please input search word: ")
    else
      let l:word = join(a:args, "")
    endif

    call unite#print_message('Searching nuget packages for "'.l:word.'"...')

    let result = unite#sources#nuget#search(l:word)

    let candidates = []
    for package in result.data
        let candidate = {
            \   'word': package.Title,
            \   'action__uri': 'https://www.nuget.org/packages/' . package.PackageRegistration.Id . '/' . package.Version,
            \   'raw_data': package
            \ }
        call add(candidates, candidate)
    endfor

    return candidates
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
