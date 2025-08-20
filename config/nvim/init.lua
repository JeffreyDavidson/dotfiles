-- Minimal Neovim setup: shada only (no swap/backup/persistent undo)
-- Tune shada and avoid creating extra state directories for now.

local fn = vim.fn

local state = fn.stdpath('state')

-- Shada directory under state (keep this so history persists)
local shada_dir  = state .. '/shada'

-- Ensure shada dir exists
if fn.isdirectory(shada_dir) == 0 then
  fn.mkdir(shada_dir, 'p')
end

-- Shada: n= marks, ' for registers, s for max item size
-- Example: keep lots of history, but cap item size
vim.o.shada = [[!,'1000,\u003c50,s10,h,%,:,/]]
-- Pin shada file explicitly under state
vim.o.shadafile = shada_dir .. '/main.shada'

-- Disable swap, backup, and persistent undo for now
vim.o.swapfile   = false
vim.o.backup     = false
vim.o.undofile   = false

-- Do not set directory/backupdir/undodir so Neovim won't use per-dir paths
-- History size
vim.o.history     = 1000

-- Optional: reduce messages on start
vim.opt.shortmess:append('I')

