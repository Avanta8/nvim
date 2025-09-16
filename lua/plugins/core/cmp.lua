local border = "single"

return {
  {
    "saghen/blink.cmp",

    -- optional: provides snippets for the snippet source
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
      },
    },

    -- use a release tag to download pre-built binaries
    version = "*",
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    event = "InsertEnter",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        -- use_nvim_cmp_as_default = true,

        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",

        kind_icons = require("core.custom").icons.kinds,
      },

      -- https://cmp.saghen.dev/configuration/reference#completion
      completion = {

        keyword = {
          range = "prefix",
        },

        trigger = {
          show_in_snippet = true,
          show_on_backspace = true,
          show_on_backspace_after_accept = true,
          show_on_backspace_after_insert_enter = true,
          show_on_keyword = true,
          show_on_trigger_character = true,
          show_on_insert = true,
          show_on_accept_on_trigger_character = true,
          show_on_insert_on_trigger_character = true,
          show_on_blocked_trigger_characters = {},
        },

        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },

        accept = {
          auto_brackets = {
            enabled = true,

            override_brackets_for_filetypes = {},
          },
        },

        menu = {
          border = border,

          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon", "kind" }, { "label", "label_description", gap = 1 } },
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
          update_delay_ms = 50,
          treesitter_highlighting = true,
          window = {
            border = border,
          },
        },

        ghost_text = {
          enabled = false,
        },
      },

      fuzzy = {
        -- use_typo_resistance = false,
        -- use_frecency = false,
        -- use_proximity = false,
        -- sorts = { "kind" },
      },

      keymap = {
        preset = "none",

        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },

        ["<C-g>"] = { "cancel" },
        ["<C-e>"] = { "select_and_accept" },
        ["<CR>"] = { "accept", "fallback" },

        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up" },
        ["<C-f>"] = { "scroll_documentation_down" },

        ["<C-h>"] = { "snippet_backward" },
        ["<C-l>"] = { "snippet_forward" },
      },

      signature = {
        enabled = false,
        window = {
          border = border,
        },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      cmdline = {
        keymap = { preset = "inherit" },
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
          menu = { auto_show = true },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
