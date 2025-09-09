-- Neovim options configuration
local opt = vim.opt

-- Tab settings
opt.tabstop = 4         -- Number of spaces that a <Tab> in the file counts for
opt.shiftwidth = 4      -- Number of spaces to use for each step of (auto)indent
opt.expandtab = true    -- Use spaces instead of tabs
opt.smartindent = true  -- Smart autoindenting when starting a new line

-- Line numbers
opt.number = true       -- Show line numbers
opt.relativenumber = true -- Show relative line numbers

-- Search settings
opt.ignorecase = true   -- Ignore case in search patterns
opt.smartcase = true    -- Override ignorecase if search pattern contains uppercase
opt.hlsearch = false    -- Don't highlight search results
opt.incsearch = true    -- Show search matches as you type

-- Appearance
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.signcolumn = "yes"   -- Always show the sign column
opt.wrap = false         -- Don't wrap lines
opt.scrolloff = 8        -- Keep 8 lines above/below cursor when scrolling
opt.sidescrolloff = 8    -- Keep 8 columns left/right of cursor when scrolling
opt.colorcolumn = "80"   -- Show a column at 80 characters

-- File handling
opt.backup = false       -- Don't create backup files
opt.writebackup = false  -- Don't create backup before overwriting
opt.swapfile = false     -- Don't create swap files
opt.undofile = true      -- Enable persistent undo

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" } -- Better completion experience

-- Split behavior
opt.splitbelow = true    -- Horizontal splits go below current window
opt.splitright = true    -- Vertical splits go to the right of current window

-- Performance
opt.updatetime = 250     -- Faster completion (default is 4000ms)
opt.timeoutlen = 300     -- Time to wait for a mapped sequence to complete

-- Mouse support
opt.mouse = "a"          -- Enable mouse support in all modes

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard

-- Cursor
opt.cursorline = true    -- Highlight the current line

-- Folding
opt.foldmethod = "indent" -- Fold based on indentation
opt.foldlevel = 99       -- Don't fold by default

-- Wild menu
opt.wildmenu = true      -- Enable enhanced command line completion
opt.wildmode = { "longest:full", "full" } -- Command line completion mode
