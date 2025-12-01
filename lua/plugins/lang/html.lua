local lang = require("core.lang_setup")

-- Stop neovim from recognizing html files with templates as htmldjango
vim.filetype.add({
  extension = {
    html = "html",
  },
})

-- SCSS
lang.add_ensure_installed({ "css-lsp", "some-sass-language-server" })

-- vim.lsp.enable("cssls")
vim.lsp.enable("somesass_ls")

lang.set_formatters("scss", { "prettier" })
-- lang.set_formatters("html", { "prettier" })

-- HTML + Jinja
lang.add_ensure_installed({ "jinja-lsp" })

vim.lsp.config.jinja_lsp = {
  filetypes = { "jinja", "htmldjango", "html" },
  -- Only actiavate jinja_lsp if a jinja-lsp.toml file is found
  root_dir = function(bufnr, on_dir)
    local lspconfig = require("lspconfig")
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root_dir = lspconfig.util.root_pattern("jinja-lsp.toml")(fname)

    if root_dir then
      on_dir(root_dir)
    end
  end,
}

vim.lsp.enable({ "jinja_lsp" })

lang.add_ensure_installed("djlint")
lang.set_formatters("htmldjango", { "djlint" })
lang.set_formatters("html", { "djlint" })
lang.set_formatters("jinja", { "djlint" })

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local conform_util = require("conform.util")
      local extend_opts = {
        formatters = {
          djlint = {
            require_cwd = true,
            -- Only run djlint if a djlint.toml or .djlintrc file is found
            cwd = conform_util.root_file({ "djlint.toml", ".djlintrc" }),
          },
        },
      }
      return vim.tbl_deep_extend("force", opts, extend_opts)
    end,
  },
}
