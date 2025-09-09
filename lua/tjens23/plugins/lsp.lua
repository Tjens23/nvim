-- LSP configuration for Neovim
-- Requires: nvim-lspconfig, mason.nvim, mason-lspconfig.nvim, nvim-cmp, cmp-nvim-lsp
return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        'rafamadriz/friendly-snippets',
        'onsails/lspkind.nvim',
    },
    config = function()
        -- Fix for Lua diagnostics - declare vim as global
        ---@diagnostic disable-next-line: undefined-global
        local vim = vim

        local lspconfig = require('lspconfig')
        local mason = require('mason')
        local mason_lspconfig = require('mason-lspconfig')
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        local lspkind = require('lspkind')

        -- Load friendly snippets
        require('luasnip.loaders.from_vscode').lazy_load()

        -- Setup mason for automatic LSP server installation
        mason.setup({
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
        })

        mason_lspconfig.setup({
            ensure_installed = {
                'gopls',         -- Go
                'rust_analyzer', -- Rust
                'ts_ls',         -- JavaScript/TypeScript/React (updated from tsserver)
                'eslint',        -- JS/TS/React linting
                'jdtls',         -- Java
                'pyright',       -- Python
                'cssls',         -- CSS/SCSS
                'tailwindcss',   -- Tailwind CSS
                'lua_ls',        -- Lua
            },
            automatic_installation = true,
        })

        -- Enhanced nvim-cmp capabilities for completion and autosuggestions
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
        if cmp_nvim_lsp_ok then
            capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
        end

        -- Enable additional completion capabilities for better autosuggestions
        capabilities.textDocument.completion.completionItem = {
            documentationFormat = { "markdown", "plaintext" },
            snippetSupport = true,
            preselectSupport = true,
            insertReplaceSupport = true,
            labelDetailsSupport = true,
            deprecatedSupport = true,
            commitCharactersSupport = true,
            tagSupport = { valueSet = { 1 } },
            resolveSupport = {
                properties = {
                    "documentation",
                    "detail",
                    "additionalTextEdits",
                },
            },
        }

        -- Enhanced nvim-cmp setup for better autosuggestions and completion
        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered({
                    border = "rounded",
                    scrollbar = "║",
                }),
                documentation = cmp.config.window.bordered({
                    border = "rounded",
                }),
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true
                }),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp', priority = 1000 },
                { name = 'luasnip', priority = 750 },
                { name = 'buffer', priority = 500, keyword_length = 3 },
                { name = 'path', priority = 250 },
            }),
            formatting = {
                format = lspkind.cmp_format({
                    mode = 'symbol_text',
                    maxwidth = 50,
                    ellipsis_char = '...',
                    show_labelDetails = true,
                    before = function(entry, vim_item)
                        return vim_item
                    end
                })
            },
            experimental = {
                ghost_text = {
                    hl_group = "LspCodeLens"
                },
            },
            performance = {
                debounce = 60,
                throttle = 30,
                fetching_timeout = 500,
            },
        })

        -- Use buffer source for `/` and `?`
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

        -- Use cmdline & path source for ':'
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            })
        })

        -- Common on_attach function for keymaps and formatting
        local on_attach = function(client, bufnr)
            local buf_map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            -- Enhanced navigation and information keymaps
            buf_map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
            buf_map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
            buf_map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
            buf_map('n', 'gt', vim.lsp.buf.type_definition, 'Go to type definition')
            buf_map('n', 'K', vim.lsp.buf.hover, 'Hover documentation')
            buf_map('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature help')
            buf_map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
            buf_map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code actions')
            buf_map('n', 'gr', vim.lsp.buf.references, 'Show references')
            buf_map('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, 'Format document')
            buf_map('v', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, 'Format selection')

            -- Diagnostic navigation
            buf_map('n', '[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
            buf_map('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')
            buf_map('n', '<leader>d', vim.diagnostic.open_float, 'Show diagnostic')
            buf_map('n', '<leader>q', vim.diagnostic.setloclist, 'Diagnostic list')

            -- Workspace management
            buf_map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, 'Add workspace folder')
            buf_map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Remove workspace folder')
            buf_map('n', '<leader>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, 'List workspace folders')

            -- Enable inlay hints if supported (fixed API usage)
            if client.supports_method('textDocument/inlayHint') then
                vim.lsp.inlay_hint.enable(bufnr, true)
            end

            -- Format on save if supported
            if client.supports_method('textDocument/formatting') then
                vim.api.nvim_create_autocmd('BufWritePre', {
                    buffer = bufnr,
                    callback = function() vim.lsp.buf.format({ bufnr = bufnr, async = false }) end,
                })
            end
        end

        -- Configure diagnostics
        vim.diagnostic.config({
            virtual_text = {
                spacing = 4,
                prefix = "●",
            },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })

        -- Go (gopls)
        lspconfig.gopls.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                        unreachable = true,
                        fillstruct = true,
                    },
                    staticcheck = true,
                    gofumpt = true,
                    codelenses = {
                        gc_details = false,
                        generate = true,
                        regenerate_cgo = true,
                        run_govulncheck = true,
                        test = true,
                        tidy = true,
                        upgrade_dependency = true,
                        vendor = true,
                    },
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                },
            },
        }

        -- Rust (rust_analyzer)
        lspconfig.rust_analyzer.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                ['rust-analyzer'] = {
                    cargo = {
                        allFeatures = true,
                        loadOutDirsFromCheck = true,
                        runBuildScripts = true,
                    },
                    checkOnSave = {
                        allFeatures = true,
                        command = 'clippy',
                        extraArgs = { '--no-deps' },
                    },
                    procMacro = {
                        enable = true,
                        ignored = {
                            ["async-trait"] = { "async_trait" },
                            ["napi-derive"] = { "napi" },
                            ["async-recursion"] = { "async_recursion" },
                        },
                    },
                    inlayHints = {
                        bindingModeHints = {
                            enable = false,
                        },
                        chainingHints = {
                            enable = true,
                        },
                        closingBraceHints = {
                            enable = true,
                            minLines = 25,
                        },
                        closureReturnTypeHints = {
                            enable = "never",
                        },
                        lifetimeElisionHints = {
                            enable = "never",
                            useParameterNames = false,
                        },
                        maxLength = 25,
                        parameterHints = {
                            enable = true,
                        },
                        reborrowHints = {
                            enable = "never",
                        },
                        renderColons = true,
                        typeHints = {
                            enable = true,
                            hideClosureInitialization = false,
                            hideNamedConstructor = false,
                        },
                    },
                },
            },
        }

        -- JavaScript/TypeScript/React/React Native (ts_ls - updated from tsserver)
        lspconfig.ts_ls.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            init_options = {
                preferences = {
                    disableSuggestions = false,
                }
            },
            settings = {
                completions = {
                    completeFunctionCalls = true
                },
                typescript = {
                    inlayHints = {
                        includeInlayParameterNameHints = 'all',
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    },
                    suggest = {
                        includeCompletionsForModuleExports = true,
                    },
                },
                javascript = {
                    inlayHints = {
                        includeInlayParameterNameHints = 'all',
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayVariableTypeHints = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayEnumMemberValueHints = true,
                    },
                    suggest = {
                        includeCompletionsForModuleExports = true,
                    },
                },
            },
            filetypes = {
                'javascript',
                'javascriptreact',
                'javascript.jsx',
                'typescript',
                'typescriptreact',
                'typescript.tsx'
            },
        }

        -- ESLint for JS/TS/React/React Native linting
        lspconfig.eslint.setup {
            on_attach = function(client, bufnr)
                on_attach(client, bufnr)
                -- Auto-fix on save for ESLint
                vim.api.nvim_create_autocmd('BufWritePre', {
                    buffer = bufnr,
                    command = 'EslintFixAll',
                })
            end,
            capabilities = capabilities,
            settings = {
                workingDirectory = { mode = "auto" },
                format = { enable = true },
                lint = { enable = true },
                run = "onType",
                codeActionOnSave = {
                    enable = true,
                    mode = "all"
                },
            },
            filetypes = {
                'javascript',
                'javascriptreact',
                'javascript.jsx',
                'typescript',
                'typescriptreact',
                'typescript.tsx'
            },
        }

        -- Java (jdtls)
        lspconfig.jdtls.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                java = {
                    configuration = {
                        updateBuildConfiguration = "interactive",
                    },
                    completion = {
                        favoriteStaticMembers = {
                            "org.hamcrest.MatcherAssert.assertThat",
                            "org.hamcrest.Matchers.*",
                            "org.hamcrest.CoreMatchers.*",
                            "org.junit.jupiter.api.Assertions.*",
                            "java.util.Objects.requireNonNull",
                            "java.util.Objects.requireNonNullElse",
                            "org.mockito.Mockito.*"
                        },
                        importOrder = {
                            "java",
                            "javax",
                            "com",
                            "org"
                        },
                    },
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999,
                        },
                    },
                    codeGeneration = {
                        toString = {
                            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                        },
                        useBlocks = true,
                    },
                },
            },
        }

        -- Python (pyright)
        lspconfig.pyright.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        diagnosticMode = "workspace",
                        useLibraryCodeForTypes = true,
                        typeCheckingMode = "basic"
                    }
                }
            }
        }

        -- CSS/SCSS Language Server
        lspconfig.cssls.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                css = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore"
                    }
                },
                scss = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore"
                    }
                }
            },
            filetypes = { "css", "scss", "less" }
        }

        -- Tailwind CSS Language Server
        lspconfig.tailwindcss.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                tailwindCSS = {
                    classAttributes = { "class", "className", "classList", "ngClass" },
                    lint = {
                        cssConflict = "warning",
                        invalidApply = "error",
                        invalidConfigPath = "error",
                        invalidScreen = "error",
                        invalidTailwindDirective = "error",
                        invalidVariant = "error",
                        recommendedVariantOrder = "warning"
                    },
                    validate = true
                }
            },
            filetypes = {
                "aspnetcorerazor",
                "astro",
                "astro-markdown",
                "blade",
                "clojure",
                "django-html",
                "htmldjango",
                "edge",
                "eelixir",
                "elixir",
                "ejs",
                "erb",
                "eruby",
                "gohtml",
                "haml",
                "handlebars",
                "hbs",
                "html",
                "html-eex",
                "heex",
                "jade",
                "leaf",
                "liquid",
                "markdown",
                "mdx",
                "mustache",
                "njk",
                "nunjucks",
                "php",
                "razor",
                "slim",
                "twig",
                "css",
                "less",
                "postcss",
                "sass",
                "scss",
                "stylus",
                "sugarss",
                "javascript",
                "javascriptreact",
                "reason",
                "rescript",
                "typescript",
                "typescriptreact",
                "vue",
                "svelte"
            }
        }

        -- Lua Language Server
        lspconfig.lua_ls.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        globals = { 'vim' },
                        disable = { 'missing-fields' }
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false,
                    },
                    completion = {
                        callSnippet = "Replace"
                    },
                    hint = {
                        enable = true,
                    },
                },
            },
        }

        -- LSP server status signs in gutter
        local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
    end,
}
