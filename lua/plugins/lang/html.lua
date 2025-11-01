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
}

vim.lsp.enable({ "jinja_lsp" })

lang.add_ensure_installed("djlint")
lang.set_formatters("htmldjango", { "djlint" })
lang.set_formatters("html", { "djlint" })
lang.set_formatters("jinja", { "djlint" })

return {}
