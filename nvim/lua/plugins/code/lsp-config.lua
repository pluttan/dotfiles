---@diagnostic disable: trailing-space
return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
        opts = {
            auto_install = true,
        },
        config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {

					"lua_ls",
					"tsserver",
					"texlab",
					"clangd",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.tsserver.setup({ capabilities = capabilities })
			lspconfig.texlab.setup({ capabilities = capabilities })
			lspconfig.clangd.setup({ capabilities = capabilities })

			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, {})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.code_actions.eslint,
                    -- cpp
				    null_ls.builtins.formatting.clang_format,
                },
			})

			vim.keymap.set("n", "<M-f>", vim.lsp.buf.format, {})
		end,
	},
}
