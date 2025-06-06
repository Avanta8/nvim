vim.g.no_rust_maps = true

return {
  require("core.lang_setup").create_config({
    rust_analyzer = {
      mason = false,
      setup = false,
    },
  }),

  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    ft = { "rust" },

    init = function()
      vim.g.rustaceanvim = {
        -- tools = {
        --   hover_actions = {
        --     replace_builtin_hover = false,
        --   },
        --   code_actions = {
        --     ui_select_fallback = true,
        --   },
        -- },
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              inlayHints = {
                bindingModeHints = {
                  enable = true,
                },
                closingBraceHints = {
                  enable = true,
                  minLines = 1,
                },
                closureCaptureHints = {
                  enable = false,
                  -- enable = true,
                },
                closureReturnTypeHints = {
                  enable = "always",
                },
                discriminantHints = {
                  enable = true,
                },
                -- expressionAdjustmentHints = {
                --   -- enable = "reborrow_only",
                --   enable = "always",
                -- },
                implicitDrops = {
                  enable = false,
                  -- enable = true,
                },
                lifetimeElisionHints = {
                  enable = "always",
                  useParameterNames = true,
                },
                rangeExclusiveHints = {
                  enable = true,
                },
                hideNamedConstructor = {
                  enable = true,
                },
              },
            },
          },
        },
      }
    end,
  },
}
