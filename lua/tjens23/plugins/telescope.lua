return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                ---@diagnostic disable-next-line: undefined-global
                return vim.fn.executable 'make' == 1
            end,
        },
        'nvim-telescope/telescope-ui-select.nvim',
        'nvim-tree/nvim-web-devicons',
        'nvim-telescope/telescope-file-browser.nvim',
        'nvim-telescope/telescope-project.nvim',
        'nvim-telescope/telescope-symbols.nvim',
        'nvim-telescope/telescope-frecency.nvim',
        'nvim-telescope/telescope-live-grep-args.nvim',
    },
    config = function()
        -- Fix for Lua diagnostics - declare vim as global
        ---@diagnostic disable-next-line: undefined-global
        local vim = vim

        local telescope = require('telescope')
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')
        local builtin = require('telescope.builtin')

        telescope.setup({
            defaults = {
                -- Appearance
                prompt_prefix = '🔍 ',
                selection_caret = '➤ ',
                entry_prefix = '  ',
                multi_icon = '✓',

                -- Behavior
                sorting_strategy = 'ascending',
                layout_strategy = 'horizontal',
                layout_config = {
                    horizontal = {
                        prompt_position = 'top',
                        preview_width = 0.55,
                        results_width = 0.8,
                    },
                    vertical = {
                        mirror = false,
                    },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                },

                -- File filtering
                file_ignore_patterns = {
                    'node_modules',
                    '.git/',
                    '.cache',
                    '%.o',
                    '%.a',
                    '%.out',
                    '%.class',
                    '%.pdf',
                    '%.mkv',
                    '%.mp4',
                    '%.zip',
                    '%.tar.gz',
                    'target/',
                    'build/',
                    'dist/',
                    '.next/',
                    '.nuxt/',
                    'vendor/',
                    '__pycache__/',
                    '%.pyc',
                    '.DS_Store',
                },

                -- Search settings
                set_env = { ['COLORTERM'] = 'truecolor' },
                path_display = { 'truncate' },
                winblend = 0,
                border = {},
                borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
                color_devicons = true,
                use_less = true,

                -- Preview settings
                preview = {
                    mime_hook = function(filepath, bufnr, opts)
                        local is_image = function(path)
                            local image_extensions = {'png','jpg','jpeg','gif','bmp','tiff','webp','svg'}
                            local split_path = vim.split(path:lower(), '.', {plain=true})
                            local extension = split_path[#split_path]
                            return vim.tbl_contains(image_extensions, extension)
                        end
                        if is_image(filepath) then
                            local term = vim.api.nvim_open_term(bufnr, {})
                            local function send_output(_, data, _ )
                                for _, d in ipairs(data) do
                                    vim.api.nvim_chan_send(term, d .. '\r\n')
                                end
                            end
                            vim.fn.jobstart(
                                {'catimg', filepath},
                                {on_stdout=send_output, stdout_buffered=true, pty=true})
                        else
                            require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
                        end
                    end
                },

                -- Key mappings
                mappings = {
                    i = {
                        ['<C-n>'] = actions.cycle_history_next,
                        ['<C-p>'] = actions.cycle_history_prev,
                        ['<C-j>'] = actions.move_selection_next,
                        ['<C-k>'] = actions.move_selection_previous,
                        ['<C-c>'] = actions.close,
                        ['<Down>'] = actions.move_selection_next,
                        ['<Up>'] = actions.move_selection_previous,
                        ['<CR>'] = actions.select_default,
                        ['<C-x>'] = actions.select_horizontal,
                        ['<C-v>'] = actions.select_vertical,
                        ['<C-t>'] = actions.select_tab,
                        ['<C-u>'] = actions.preview_scrolling_up,
                        ['<C-d>'] = actions.preview_scrolling_down,
                        ['<PageUp>'] = actions.results_scrolling_up,
                        ['<PageDown>'] = actions.results_scrolling_down,
                        ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
                        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
                        ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
                        ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
                        ['<C-l>'] = actions.complete_tag,
                        ['<C-_>'] = actions.which_key, -- keys from pressing <C-/>
                    },
                    n = {
                        ['<esc>'] = actions.close,
                        ['<CR>'] = actions.select_default,
                        ['<C-x>'] = actions.select_horizontal,
                        ['<C-v>'] = actions.select_vertical,
                        ['<C-t>'] = actions.select_tab,
                        ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
                        ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
                        ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
                        ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
                        ['j'] = actions.move_selection_next,
                        ['k'] = actions.move_selection_previous,
                        ['H'] = actions.move_to_top,
                        ['M'] = actions.move_to_middle,
                        ['L'] = actions.move_to_bottom,
                        ['<Down>'] = actions.move_selection_next,
                        ['<Up>'] = actions.move_selection_previous,
                        ['gg'] = actions.move_to_top,
                        ['G'] = actions.move_to_bottom,
                        ['<C-u>'] = actions.preview_scrolling_up,
                        ['<C-d>'] = actions.preview_scrolling_down,
                        ['<PageUp>'] = actions.results_scrolling_up,
                        ['<PageDown>'] = actions.results_scrolling_down,
                        ['?'] = actions.which_key,
                    },
                },
            },

            pickers = {
                -- File pickers
                find_files = {
                    theme = 'dropdown',
                    previewer = false,
                    hidden = true,
                    find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
                },
                git_files = {
                    theme = 'dropdown',
                    previewer = false,
                },
                oldfiles = {
                    theme = 'dropdown',
                    previewer = false,
                },

                -- Live grep
                live_grep = {
                    additional_args = function(opts)
                        return {"--hidden"}
                    end
                },
                grep_string = {
                    additional_args = function(opts)
                        return {"--hidden"}
                    end
                },

                -- LSP pickers
                lsp_references = {
                    theme = 'cursor',
                    layout_config = {
                        cursor = {
                            height = 0.4,
                            width = 0.8,
                        }
                    }
                },
                lsp_definitions = {
                    theme = 'cursor',
                    layout_config = {
                        cursor = {
                            height = 0.4,
                            width = 0.8,
                        }
                    }
                },
                lsp_implementations = {
                    theme = 'cursor',
                    layout_config = {
                        cursor = {
                            height = 0.4,
                            width = 0.8,
                        }
                    }
                },

                -- Buffer picker
                buffers = {
                    theme = 'dropdown',
                    previewer = false,
                    sort_mru = true,
                    sort_lastused = true,
                    mappings = {
                        i = {
                            ['<c-d>'] = actions.delete_buffer,
                        },
                        n = {
                            ['dd'] = actions.delete_buffer,
                        }
                    }
                },

                -- Command palette
                commands = {
                    theme = 'ivy',
                },
                command_history = {
                    theme = 'ivy',
                },

                -- Help and man pages
                help_tags = {
                    theme = 'ivy',
                },
                man_pages = {
                    theme = 'ivy',
                },

                -- Git pickers
                git_commits = {
                    theme = 'ivy',
                },
                git_bcommits = {
                    theme = 'ivy',
                },
                git_branches = {
                    theme = 'ivy',
                },
                git_status = {
                    theme = 'ivy',
                },
                git_stash = {
                    theme = 'ivy',
                },

                -- Quickfix and location lists
                quickfix = {
                    theme = 'ivy',
                },
                loclist = {
                    theme = 'ivy',
                },

                -- Diagnostics
                diagnostics = {
                    theme = 'ivy',
                    bufnr = 0,
                },

                -- Symbols
                symbols = {
                    sources = {'emoji', 'kaomoji', 'math', 'latex'},
                },
            },

            extensions = {
                -- FZF extension for better performance
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = 'smart_case',
                },

                -- UI Select extension
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown {
                        winblend = 10,
                        width = 0.5,
                        previewer = false,
                        shorten_path = false,
                    }
                },

                -- File browser extension
                file_browser = {
                    theme = 'ivy',
                    hijack_netrw = true,
                    mappings = {
                        ['i'] = {
                            ['<A-c>'] = require('telescope._extensions.file_browser.actions').create,
                            ['<S-CR>'] = require('telescope._extensions.file_browser.actions').create_from_prompt,
                            ['<A-r>'] = require('telescope._extensions.file_browser.actions').rename,
                            ['<A-m>'] = require('telescope._extensions.file_browser.actions').move,
                            ['<A-y>'] = require('telescope._extensions.file_browser.actions').copy,
                            ['<A-d>'] = require('telescope._extensions.file_browser.actions').remove,
                            ['<C-o>'] = require('telescope._extensions.file_browser.actions').open,
                            ['<C-g>'] = require('telescope._extensions.file_browser.actions').goto_parent_dir,
                            ['<C-e>'] = require('telescope._extensions.file_browser.actions').goto_home_dir,
                            ['<C-w>'] = require('telescope._extensions.file_browser.actions').goto_cwd,
                            ['<C-t>'] = require('telescope._extensions.file_browser.actions').change_cwd,
                            ['<C-f>'] = require('telescope._extensions.file_browser.actions').toggle_browser,
                            ['<C-h>'] = require('telescope._extensions.file_browser.actions').toggle_hidden,
                            ['<C-s>'] = require('telescope._extensions.file_browser.actions').toggle_all,
                        },
                        ['n'] = {
                            ['c'] = require('telescope._extensions.file_browser.actions').create,
                            ['r'] = require('telescope._extensions.file_browser.actions').rename,
                            ['m'] = require('telescope._extensions.file_browser.actions').move,
                            ['y'] = require('telescope._extensions.file_browser.actions').copy,
                            ['d'] = require('telescope._extensions.file_browser.actions').remove,
                            ['o'] = require('telescope._extensions.file_browser.actions').open,
                            ['g'] = require('telescope._extensions.file_browser.actions').goto_parent_dir,
                            ['e'] = require('telescope._extensions.file_browser.actions').goto_home_dir,
                            ['w'] = require('telescope._extensions.file_browser.actions').goto_cwd,
                            ['t'] = require('telescope._extensions.file_browser.actions').change_cwd,
                            ['f'] = require('telescope._extensions.file_browser.actions').toggle_browser,
                            ['h'] = require('telescope._extensions.file_browser.actions').toggle_hidden,
                            ['s'] = require('telescope._extensions.file_browser.actions').toggle_all,
                        },
                    },
                },

                -- Project extension
                project = {
                    hidden_files = true,
                    theme = 'dropdown',
                    order_by = 'asc',
                    search_by = 'title',
                    sync_with_nvim_tree = true,
                },

                -- Frecency extension
                frecency = {
                    theme = 'dropdown',
                    show_scores = false,
                    show_unindexed = true,
                    ignore_patterns = {'*.git/*', '*/tmp/*', '*/node_modules/*'},
                    disable_devicons = false,
                    workspaces = {
                        ['conf'] = '/home/tjens23/.config',
                        ['docs'] = '/home/tjens23/Documents',
                        ['go'] = '/home/tjens23/go',
                        ['expo'] = '/home/tjens23/expo-create-react-native-app',
                    }
                },

                -- Live grep args extension
                live_grep_args = {
                    auto_quoting = true,
                    mappings = {
                        i = {
                            ['<C-k>'] = require('telescope-live-grep-args.actions').quote_prompt(),
                            ['<C-i>'] = require('telescope-live-grep-args.actions').quote_prompt({ postfix = ' --iglob ' }),
                        }
                    }
                }
            },
        })

        -- Load extensions
        telescope.load_extension('fzf')
        telescope.load_extension('ui-select')
        telescope.load_extension('file_browser')
        telescope.load_extension('project')
        telescope.load_extension('frecency')
        telescope.load_extension('live_grep_args')

        -- Keymaps
        local keymap = vim.keymap.set
        local opts = { silent = true, noremap = true }

        -- File finding
        keymap('n', '<leader>ff', builtin.find_files, vim.tbl_extend('force', opts, { desc = 'Find files' }))
        keymap('n', '<leader>fg', builtin.git_files, vim.tbl_extend('force', opts, { desc = 'Find git files' }))
        keymap('n', '<leader>fr', builtin.oldfiles, vim.tbl_extend('force', opts, { desc = 'Find recent files' }))
        keymap('n', '<leader>fb', builtin.buffers, vim.tbl_extend('force', opts, { desc = 'Find buffers' }))
        keymap('n', '<leader>fh', builtin.help_tags, vim.tbl_extend('force', opts, { desc = 'Find help' }))
        keymap('n', '<leader>fm', builtin.man_pages, vim.tbl_extend('force', opts, { desc = 'Find man pages' }))
        keymap('n', '<leader>fk', builtin.keymaps, vim.tbl_extend('force', opts, { desc = 'Find keymaps' }))
        keymap('n', '<leader>fc', builtin.commands, vim.tbl_extend('force', opts, { desc = 'Find commands' }))
        keymap('n', '<leader>fC', builtin.command_history, vim.tbl_extend('force', opts, { desc = 'Find command history' }))

        -- Search
        keymap('n', '<leader>sg', builtin.live_grep, vim.tbl_extend('force', opts, { desc = 'Search grep' }))
        keymap('n', '<leader>sG', telescope.extensions.live_grep_args.live_grep_args, vim.tbl_extend('force', opts, { desc = 'Search grep with args' }))
        keymap('n', '<leader>sw', builtin.grep_string, vim.tbl_extend('force', opts, { desc = 'Search word under cursor' }))
        keymap('n', '<leader>sb', builtin.current_buffer_fuzzy_find, vim.tbl_extend('force', opts, { desc = 'Search buffer' }))
        keymap('n', '<leader>ss', builtin.symbols, vim.tbl_extend('force', opts, { desc = 'Search symbols' }))

        -- LSP
        keymap('n', '<leader>lr', builtin.lsp_references, vim.tbl_extend('force', opts, { desc = 'LSP references' }))
        keymap('n', '<leader>ld', builtin.lsp_definitions, vim.tbl_extend('force', opts, { desc = 'LSP definitions' }))
        keymap('n', '<leader>li', builtin.lsp_implementations, vim.tbl_extend('force', opts, { desc = 'LSP implementations' }))
        keymap('n', '<leader>lt', builtin.lsp_type_definitions, vim.tbl_extend('force', opts, { desc = 'LSP type definitions' }))
        keymap('n', '<leader>ls', builtin.lsp_document_symbols, vim.tbl_extend('force', opts, { desc = 'LSP document symbols' }))
        keymap('n', '<leader>lS', builtin.lsp_workspace_symbols, vim.tbl_extend('force', opts, { desc = 'LSP workspace symbols' }))
        keymap('n', '<leader>lD', builtin.diagnostics, vim.tbl_extend('force', opts, { desc = 'LSP diagnostics' }))

        -- Git
        keymap('n', '<leader>gc', builtin.git_commits, vim.tbl_extend('force', opts, { desc = 'Git commits' }))
        keymap('n', '<leader>gC', builtin.git_bcommits, vim.tbl_extend('force', opts, { desc = 'Git buffer commits' }))
        keymap('n', '<leader>gb', builtin.git_branches, vim.tbl_extend('force', opts, { desc = 'Git branches' }))
        keymap('n', '<leader>gs', builtin.git_status, vim.tbl_extend('force', opts, { desc = 'Git status' }))
        keymap('n', '<leader>gS', builtin.git_stash, vim.tbl_extend('force', opts, { desc = 'Git stash' }))

        -- Extensions
        keymap('n', '<leader>fe', telescope.extensions.file_browser.file_browser, vim.tbl_extend('force', opts, { desc = 'File browser' }))
        keymap('n', '<leader>fp', telescope.extensions.project.project, vim.tbl_extend('force', opts, { desc = 'Find projects' }))
        keymap('n', '<leader>fF', telescope.extensions.frecency.frecency, vim.tbl_extend('force', opts, { desc = 'Frecency files' }))

        -- Quickfix and location lists
        keymap('n', '<leader>qf', builtin.quickfix, vim.tbl_extend('force', opts, { desc = 'Quickfix list' }))
        keymap('n', '<leader>ql', builtin.loclist, vim.tbl_extend('force', opts, { desc = 'Location list' }))

        -- Resume last picker
        keymap('n', '<leader><leader>', builtin.resume, vim.tbl_extend('force', opts, { desc = 'Resume last picker' }))
    end,
}
