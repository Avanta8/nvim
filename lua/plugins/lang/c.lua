return {
  require("core.lang_setup").create_config({
    clangd = {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        -- "--fallback-style=Mozilla",
        -- "--fallback-style='{BasedOnStyle: Mozilla}'",
        -- "--fallback-style='{ BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 0, AllowShortIfStatementsOnASingleLine: false, AllowShortBlocksOnASingleLine: Empty }'",
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
      },
      capabilities = {
        offsetEncoding = { "utf-16" },
      },
    },
  }),
}
