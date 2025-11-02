local lang = require("core.lang_setup")

lang.add_ensure_installed({ "typescript-language-server", "prettier", "eslint-lsp" })
lang.set_formatters("javascript", { "prettier" })

vim.lsp.config.eslint = {}

vim.lsp.enable("eslint")

return {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
}
