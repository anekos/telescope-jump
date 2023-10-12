function s:on_dir_changed(dir)
  call system(['jump', 'chdir', a:dir])
endfunction

augroup Jump
  autocmd!
  autocmd DirChanged * silent! call s:on_dir_changed(v:event['cwd'])
augroup END
