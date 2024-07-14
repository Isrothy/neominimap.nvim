" plugin/neominimap.vim

if has('nvim') && exists('*luaeval')
    lua require('neominimap').setup()
endif
