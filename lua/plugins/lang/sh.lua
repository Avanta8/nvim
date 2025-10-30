local lang = require("core.lang_setup")

vim.lsp.enable("bashls")

lang.add_ensure_installed({ "bash-language-server", "shfmt" })
lang.set_formatters("sh", { "shfmt" })

return {}
