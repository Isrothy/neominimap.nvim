" plugin/neominimap.vim

if has('nvim') && exists('*luaeval')
    lua require('neominimap').setup()
    
    command! NeominimapOpen lua require('neominimap').open_minimap()
    command! NeominimapClose lua require('neominimap').close_minimap()
    command! NeominimapToggle lua require('neominimap').toggle_minimap()
endif
