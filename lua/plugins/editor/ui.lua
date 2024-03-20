local custom = require("core.custom")
local utils = require("core.utils")

return {
  {
    "echasnovski/mini.notify",
    lazy = false,
    opts = function()
      return {
        window = {
          config = function()
            local has_statusline = vim.o.laststatus > 0
            local bottom_space = vim.o.cmdheight + (has_statusline and 1 or 0)
            return { anchor = "SE", col = vim.o.columns, row = vim.o.lines - bottom_space }
          end,
        },
      }
    end,
    keys = {
      {
        "<leader>sn",
        function()
          local win = utils.create_global_floating_win({
            height = 0.8,
            width = 0.8,
          })
          require("mini.notify").show_history()

          -- FIXME:
          -- error if you open the history while it is already being displayed.

          vim.api.nvim_set_option_value("modifiable", false, { buf = 0 })
          vim.api.nvim_set_option_value("buflisted", false, { buf = 0 })
          -- NOTE: If we set the buffer to unmodifiable, then we must set
          -- bufhidden to unload, wipe or delete, otherwise notify will error if
          -- we close then reopen the history.
          vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = 0 })
          vim.api.nvim_set_option_value("winfixbuf", true, { win = win })
        end,
        desc = "Show notify",
      },
    },
    config = function(_, opts)
      local notify = require("mini.notify")
      notify.setup(opts)

      vim.notify = notify.make_notify({
        ERROR = { duration = 5000 },
        WARN = { duration = 5000 },
        INFO = { duration = 5000 },
        DEBUG = { duration = 3000 },
        TRACE = { duration = 3000 },
        OFF = { duration = 3000 },
      })
    end,
  },

  -- Nice UI for pickers. eg, code actions
  {
    "stevearc/dressing.nvim",
    lazy = true,
    opts = {
      input = {
        insert_only = false,
        start_in_insert = false,
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {
      indent = {
        char = "▏",
        tab_char = "▏",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
    main = "ibl",
  },

  {
    "echasnovski/mini.indentscope",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = function()
      return {
        draw = {
          delay = 0,
          animation = require("mini.indentscope").gen_animation.none(),
        },
        mappings = {
          -- Textobjects
          object_scope = "ii",
          object_scope_with_border = "ai",

          -- Motions (jump to respective border line; if not present - body line)
          goto_top = "[i",
          goto_bottom = "]i",
        },
        options = {
          try_as_border = true,
        },
        symbol = "▏",
        -- symbol = "│",
      }
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = {
          { "branch", icon = "" },
          {
            "diagnostics",
            always_visible = true,
            sections = { "hint", "info", "warn", "error" },
            symbols = {
              error = custom.icons.diagnostics.Error,
              warn = custom.icons.diagnostics.Warn,
              info = custom.icons.diagnostics.Info,
              hint = custom.icons.diagnostics.Hint,
            },
          },
          {
            "diff",
            symbols = {
              added = custom.icons.git.added,
              modified = custom.icons.git.modified,
              removed = custom.icons.git.removed,
            },
          },
        },
        lualine_c = { "filename", "navic" },
        lualine_x = {
          function()
            local reg = vim.fn.reg_recording()
            if reg == "" then
              return ""
            end
            return "recording to " .. reg
          end,
          "searchcount",
        },
        lualine_y = { "encoding", "fileformat", "filetype" },
        lualine_z = { "progress", "location" },
      },
      -- HACK: I need this section here: (lualine_a with buffers).
      -- Othersize, lualine is bugged with cmdheight=0 and sometimes disappears.
      tabline = {
        -- lualine_a = { "buffers" },
      },
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        refresh = {
          statusline = 100,
        },
      },
      extensions = { "neo-tree", "lazy", "mason", "quickfix" },
    },
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "luukvbaal/statuscol.nvim",
    event = "VimEnter",
    opts = function()
      local builtin = require("statuscol.builtin")
      return {
        relculright = true,
        setopt = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          {
            sign = {
              namespace = { "gitsigns" },
              maxwidth = 1,
              colwidth = 1,
            },
            click = "v:lua.ScSa",
          },
          {
            sign = {
              namespace = { "diagnostic" },
              maxwidth = 1,
              colwidth = 2,
            },
            click = "v:lua.ScSa",
          },
          { text = { " " } },
          { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
          { text = { " " } },
        },
        ft_ignore = {
          "help",
          "vim",
          "alpha",
          "dashboard",
          "neo-tree",
          "lazy",
        },
      }
    end,
  },

  {
    "nvimdev/dashboard-nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      "folke/persistence.nvim",
    },
    event = "VimEnter",
    opts = function()
      local logo = string.rep("\n", 8) .. require("core.custom").logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
        -- stylua: ignore
        center = {
          { action = "Telescope find_files",                                     desc = " Find file",       icon = " ", key = "f" },
          { action = "ene | startinsert",                                        desc = " New file",        icon = " ", key = "n" },
          { action = "Telescope oldfiles",                                       desc = " Recent files",    icon = " ", key = "r" },
          { action = "Telescope live_grep",                                      desc = " Find text",       icon = " ", key = "g" },
          { action = 'lua require("persistence").load()',                        desc = " Restore Session", icon = " ", key = "s" },
          { action = "Lazy",                                                     desc = " Lazy",            icon = "󰒲 ", key = "l" },
          { action = "qa",                                                       desc = " Quit",            icon = " ", key = "q" },
        },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "DashboardLoaded",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      return opts
    end,
  },
}
