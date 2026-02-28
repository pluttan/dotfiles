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
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"texlab",
					"clangd",
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Новый формат для nvim 0.11+
			vim.lsp.config("lua_ls", { capabilities = capabilities })
			vim.lsp.config("ts_ls", { capabilities = capabilities })
			vim.lsp.config("texlab", { capabilities = capabilities })
			vim.lsp.config("clangd", { capabilities = capabilities })

			vim.lsp.enable({ "lua_ls", "ts_ls", "texlab", "clangd" })

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
					-- cpp
					null_ls.builtins.formatting.clang_format,
				},
			})

			vim.keymap.set("n", "<M-f>", vim.lsp.buf.format, {})
		end,
	},
}
