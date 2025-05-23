local utils = require("core.utils")

return {
  {
    enabled = false,
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
        rule("|", "|", { "rust", "go", "lua" }):with_move(cond.after_regex("|")),
      })
    end,
  },

  {
    "echasnovski/mini.pairs",
    opts = {
      modes = {
        insert = true,
        command = true,
      },

      mappings = {
        ["<"] = { action = "open", pair = "<>", neigh_pattern = "%S." },
        [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },

        -- ["|"] = { action = "closeopen", pair = "||", neigh_pattern = "[^\\]." },
      },
    },
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
    "smoka7/hop.nvim",
    opts = {
      -- keys = "etovxqpdygfblzhckisuran",
      keys = "jfkdls;ahgieurowmv,c.xpq/z",
      multi_windows = true,
    },
    keys = function()
      local hop = require("hop")
      return {
        { "sj", hop.hint_words },
      }
    end,
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
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          g = comment.textobject,
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          m = function(ai_type)
            local start_line, end_line = 1, vim.fn.line("$")
            if ai_type == "i" then
              -- Skip first and last blank lines for `i` textobject
              local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
              -- Do nothing for buffer with all blanks
              if first_nonblank == 0 or last_nonblank == 0 then
                return { from = { line = start_line, col = 1 } }
              end
              start_line, end_line = first_nonblank, last_nonblank
            end

            local to_col = math.max(vim.fn.getline(end_line):len(), 1)
            return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
          end, -- buffer
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)

      -- register all text objects with which-key
      utils.on_load("which-key.nvim", function()
        vim.schedule(function()
          local objects = {
            { " ", desc = "whitespace" },
            { '"', desc = '" string' },
            { "'", desc = "' string" },
            { "(", desc = "() block" },
            { ")", desc = "() block with ws" },
            { "<", desc = "<> block" },
            { ">", desc = "<> block with ws" },
            { "?", desc = "user prompt" },
            { "U", desc = "use/call without dot" },
            { "[", desc = "[] block" },
            { "]", desc = "[] block with ws" },
            { "_", desc = "underscore" },
            { "`", desc = "` string" },
            { "a", desc = "argument" },
            { "b", desc = ")]} block" },
            { "g", desc = "comment" },
            { "d", desc = "digit(s)" },
            { "e", desc = "CamelCase / snake_case" },
            { "f", desc = "function" },
            { "c", desc = "class" },
            { "i", desc = "indent" },
            { "m", desc = "entire file" },
            { "o", desc = "block, conditional, loop" },
            { "q", desc = "quote `\"'" },
            { "t", desc = "tag" },
            { "u", desc = "use/call" },
            { "{", desc = "{} block" },
            { "}", desc = "{} with ws" },
          }

          ---@type wk.Spec[]
          local ret = { mode = { "o", "x" } }
          ---@type table<string, string>
          local mappings = vim.tbl_extend("force", {}, {
            around = "a",
            inside = "i",
            around_next = "an",
            inside_next = "in",
            around_last = "al",
            inside_last = "il",
          }, opts.mappings or {})
          mappings.goto_left = nil
          mappings.goto_right = nil

          for name, prefix in pairs(mappings) do
            name = name:gsub("^around_", ""):gsub("^inside_", "")
            ret[#ret + 1] = { prefix, group = name }
            for _, obj in ipairs(objects) do
              local desc = obj.desc
              if prefix:sub(1, 1) == "i" then
                desc = desc:gsub(" with ws", "")
              end
              ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
            end
          end
          require("which-key").add(ret, { notify = false })

          -- ---@type table<string, string|table>
          -- local i = {
          --   [" "] = "Whitespace",
          --   ['"'] = 'Balanced "',
          --   ["'"] = "Balanced '",
          --   ["`"] = "Balanced `",
          --   ["("] = "Balanced (",
          --   [")"] = "Balanced ) including white-space",
          --   [">"] = "Balanced > including white-space",
          --   ["<lt>"] = "Balanced <",
          --   ["]"] = "Balanced ] including white-space",
          --   ["["] = "Balanced [",
          --   ["}"] = "Balanced } including white-space",
          --   ["{"] = "Balanced {",
          --   ["?"] = "User Prompt",
          --   ["/"] = "Comment",
          --   _ = "Underscore",
          --   a = "Argument",
          --   b = "Balanced ), ], }",
          --   c = "Comment",
          --   f = "Function",
          --   g = "Class",
          --   o = "Block, conditional, loop",
          --   q = "Quote `, \", '",
          --   t = "Tag",
          -- }
          -- local a = vim.deepcopy(i)
          -- for k, v in pairs(a) do
          --   a[k] = v:gsub(" including.*", "")
          -- end
          --
          -- local ic = vim.deepcopy(i)
          -- local ac = vim.deepcopy(a)
          -- for key, name in pairs({ n = "Next", l = "Last" }) do
          --   i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
          --   a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
          -- end
          -- require("which-key").register({
          --   mode = { "o", "x" },
          --   i = i,
          --   a = a,
          -- })
        end)
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
