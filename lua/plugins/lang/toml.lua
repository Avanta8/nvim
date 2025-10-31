local lang = require("core.lang_setup")

vim.lsp.enable("taplo")

lang.add_ensure_installed("taplo")
lang.set_formatters("toml", { "taplo" })

return {}
