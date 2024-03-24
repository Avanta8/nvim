local core_utils = require("core.utils")

return {
  -- Autopair brackets
  {
    "altermo/ultimate-autopair.nvim",
    event = { "InsertEnter", "CmdlineEnter" },
    branch = "v0.6", --recommended as each new version will have breaking changes
    opts = function(_, opts)
      if true then
        return {}
      end
      local function prev_line_text()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line_text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        local prev_text = line_text:sub(1, col)
        return prev_text
      end

      local function matches(patterns)
        local prev_text = prev_line_text()
        for _, pattern in ipairs(patterns) do
          if prev_text:find(pattern) then
            return true
          end
        end
        return false
      end

      return {
        {
          "<",
          ">",
          cond = function(a, b, c)
            -- for k, v in pairs(a) do
            --   vim.print(k, v)
            -- end
            -- vim.print(getmetatable(b))
            local t = getmetatable(b)
            if t ~= nil and t.__index.key == ">" then
              return true
            end
            -- print(type(t))
            -- vim.print(t.__index)
            -- print(t.__index.key)
            -- for k, v in getmetatable(b) do
            --   print(k, v)
            -- end
            -- if getmetatable(b).__index.key == ">" then
            --   return true
            -- end
            local patterns = {
              ":$",
              "%w$",
            }
            return matches(patterns)
          end,
          fly = true,
          dosuround = true,
          newline = true,
          space = true,
          ft = { "rust" },
        },
      }
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
        -- char = {
        --   enabled = true,
        --   -- jump_labels = true,
        --   multi_line = false,
        --   char_actions = function(motion)
        --     return {
        --       [";"] = "right", -- set to `right` to always go right
        --       [","] = "left", -- set to `left` to always go left
        --       -- jump2d style: same case goes next, opposite case goes prev
        --       [motion] = "next",
        --       [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
        --     }
        --   end,
        --   highlight = {
        --     backdrop = false,
        --   },
        -- }
        char = {
          multi_line = false,
          keys = { "f", "F", "t", "T", [";"] = "<C-;>", [","] = "<C-,>" },
          highlight = {
            backdrop = false,
          },
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
    -- )stylua: ignore
    keys = function()
      local flash = require("flash")
      return {
        { ";", mode = { "n", "x", "o" }, flash.jump, desc = "Flash" },
        { ",", mode = { "n", "x", "o" }, flash.treesitter, desc = "Flash Treesitter" },
        { "r", mode = "o", flash.remote, desc = "Remote Flash" },
        { "R", mode = { "o", "x" }, flash.treesitter_search, desc = "Treesitter Search" },
        { "<c-s>", mode = { "c" }, flash.toggle, desc = "Toggle Flash Search" },
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
        textobject = "gc",
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
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      -- register all text objects with which-key
      core_utils.on_load("which-key.nvim", function()
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
    dependencies = core_utils.which_key_dep({
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
    opts = {},
    keys = { { "gs", "<CMD>TSJToggle<CR>" } },
  },

  {
    "echasnovski/mini.misc",
    opts = {},
  },

  -- jumplist
  {
    "LeonHeidelbach/trailblazer.nvim",
    dependencies = {
      core_utils.which_key_dep({
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
      core_utils.which_key_dep({
        ["<leader>a"] = { "arrow" },
      }),
    },
    opts = {
      show_icons = true,
      leader_key = "<leader>a",
      separate_save_and_remove = true,
      mappings = {
        toggle = "a",
        open_horizontal = "s",
      },
    },
  },

  {
    -- enabled = false,
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
