set hidden
set noswapfile

set rtp+=../plenary.nvim
set rtp+=../textobj-diagnostic.nvim
runtime! plugin/plenary.vim

lua require('textobj-diagnostic').setup()
