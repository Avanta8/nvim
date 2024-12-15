local utils = require("core.utils")

return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {},
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      local rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.setup(opts)

      npairs.add_rules({
        rule("<", ">", { "rust" }):with_pair(cond.before_regex("%a+ *", 4)):with_move(function(opts)
          return opts.char == ">"
        end),
      })

      npairs.add_rules({ rule("|", "|", { "rust", "go", "lua" }):with_move(cond.after_regex("|")) })
    end,
  },

  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "jfkdls;ahgieurowmv,c.xpq/z",
      label = {
        uppercase = false,
        after = false,
        before = true,
      },
      highlight = {
        -- backdrop = false,
      },
      modes = {
        search = {
          enabled = false,
        },

        -- Disable char mode for now as it affect dot (.) repeat with t and f actions
        char = {
          enabled = false,
        },

        treesitter = {
          label = {
            rainbow = {
              enabled = true,
            },
          },
        },
      },
    },
    keys = function()
      local flash = require("flash")
      -- stylua: ignore
      return {
        -- { ";", mode = { "n", "x", "o" }, flash.jump, desc = "Flash" },
        -- { ",", mode = { "n", "x", "o" }, flash.treesitter, desc = "Flash Treesitter" },
        { "ss", flash.jump, mode = { "n", "x", "o" }, desc = "Flash" },
        { "S", flash.treesitter, mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
        { "s<space>", flash.treesitter, mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
        { "r", flash.remote, mode = "o", desc = "Remote Flash" },
        { "R", flash.treesitter_search, mode = { "o", "x" }, desc = "Treesitter Search" },
        { "<c-s>", flash.remote, mode = { "c" }, desc = "Toggle Flash Search" },
      }
    end,
    config = function(_, opts)
      require("flash").setup(opts)
      -- core_utils.autocmd("CmdwinEnter", {
      --   group = core_utils.augroup("unbind_cr"),
      --   callback = function(event)
      --     vim.keymap.del({ "n" }, "<CR>")
      --   end,
      -- })
      -- core_utils.autocmd("CmdwinLeave", {
      --   group = core_utils.augroup("rebind_cr"),
      --   callback = function(event)
      --     vim.keymap.set({ "n" }, "<CR>", function()
      --       require("flash").jump()
      --     end, { desc = "Flash" })
      --   end,
      -- })
    end,
  },

  -- Commenting
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    dependencies = {
      { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true, opts = { enable_autocmd = false } },
    },

    keys = {
      { "<c-_>", "gcc", mode = "n", desc = "Comment line", remap = true },
      { "<c-_>", "gcgv", mode = "x", desc = "Comment selection", remap = true },
    },

    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
      -- These are the default mappings
      mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        -- Normal and Visual modes
        comment = "gc",

        -- Toggle comment on current line
        comment_line = "gcc",

        -- Toggle comment on visual selection
        comment_visual = "gc",

        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        -- Works also in Visual mode if mapping differs from `comment_visual`
        --
        -- textobject is done by mini.ai
        textobject = "",
      },
    },
  },

  -- Better a/i selections
  -- NOTE: Changes quite a lot of key mapping with a/i that aren't listed.
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      local comment = require("mini.comment")
      return {
        n_lines = 500,
        search_method = "cover",
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          ["/"] = comment.textobject,
          -- t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)

      -- register all text objects with which-key
      utils.on_load("which-key.nvim", function()
        ---@type table<string, string|table>
        local i = {
          [" "] = "Whitespace",
          ['"'] = 'Balanced "',
          ["'"] = "Balanced '",
          ["`"] = "Balanced `",
          ["("] = "Balanced (",
          [")"] = "Balanced ) including white-space",
          [">"] = "Balanced > including white-space",
          ["<lt>"] = "Balanced <",
          ["]"] = "Balanced ] including white-space",
          ["["] = "Balanced [",
          ["}"] = "Balanced } including white-space",
          ["{"] = "Balanced {",
          ["?"] = "User Prompt",
          ["/"] = "Comment",
          _ = "Underscore",
          a = "Argument",
          b = "Balanced ), ], }",
          c = "Class",
          f = "Function",
          o = "Block, conditional, loop",
          q = "Quote `, \", '",
          t = "Tag",
        }
        local a = vim.deepcopy(i)
        for k, v in pairs(a) do
          a[k] = v:gsub(" including.*", "")
        end

        local ic = vim.deepcopy(i)
        local ac = vim.deepcopy(a)
        for key, name in pairs({ n = "Next", l = "Last" }) do
          i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
          a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
        end
        require("which-key").register({
          mode = { "o", "x" },
          i = i,
          a = a,
        })
      end)
    end,
  },

  -- Swap arguments
  {
    "mizlan/iswap.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = utils.which_key_dep({
      ["<leader>i"] = { name = "iswap" },
    }),
    keys = {
      { "<leader>is", "<cmd>ISwap<cr>", desc = "Swap node" },
      { "<leader>iw", "<cmd>ISwapWith<cr>", desc = "Swap current node" },
      { "<leader>in", "<cmd>ISwapNode<cr>", desc = "Swap chosen node" },

      { "<leader>im", "<cmd>IMove<cr>", desc = "Move node" },
      { "<leader>ie", "<cmd>IMoveWith<cr>", desc = "Move current node" },
      { "<leader>ij", "<cmd>IMoveNode<cr>", desc = "Move chosen node" },
    },
  },

  -- Split / join code blocks
  {
    "Wansmer/treesj",
    opts = {
      max_join_length = 1000,
    },
    keys = { { "gs", "<CMD>TSJToggle<CR>" } },
  },

  {
    "echasnovski/mini.misc",
    opts = {},
  },

  -- jumplist
  {
    enabled = false,
    "LeonHeidelbach/trailblazer.nvim",
    dependencies = {
      utils.which_key_dep({
        ["<leader>m"] = { name = "trailblazer" },
      }),
    },
    opts = {
      trail_options = {
        trail_mark_symbol_line_indicators_enabled = true,
        symbol_line_enabled = false,
        -- number_line_color_enabled = false,
        multiple_mark_symbol_counters_enabled = false,
        trail_mark_in_text_highlights_enabled = false,
      },
      force_mappings = { -- rename this to "force_mappings" to completely override default mappings and not merge with them
        nv = { -- Mode union: normal & visual mode. Can be extended by adding i, x, ...
          motions = {
            new_trail_mark = "<leader>mm",
            track_back = "<leader>ml",
            peek_move_next_down = "<leader>mi",
            peek_move_previous_up = "<leader>mo",
            move_to_nearest = "<leader>mn",
            toggle_trail_mark_list = "<leader>mt",
          },
          actions = {
            delete_all_trail_marks = "<leader>md",
            paste_at_last_trail_mark = "<leader>mp",
            paste_at_all_trail_marks = "<leader>mP",
            -- set_trail_mark_select_mode = "<A-t>",
            -- switch_to_next_trail_mark_stack = "<A-.>",
            -- switch_to_previous_trail_mark_stack = "<A-,>",
            -- set_trail_mark_stack_sort_mode = "<A-s>",
          },
        },
      },
    },
  },

  -- jump buffers
  {
    "otavioschwanck/arrow.nvim",
    dependencies = {
      utils.which_key_dep({
        ["<leader>a"] = { "arrow" },
      }),
    },
    opts = {
      show_icons = true,
      leader_key = "<leader>a",
      buffer_leader_key = "<leader>m",
      separate_save_and_remove = true,
      mappings = {
        toggle = "a",
        open_horizontal = "s",
      },
    },
  },

  {
    enabled = false,
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = {
        enabled = true,
        -- auto_trigger = true,
        keymap = {
          accept = "<C-y>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = {
        enabled = true,
        auto_refresh = true,
      },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
}
