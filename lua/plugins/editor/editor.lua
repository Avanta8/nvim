local core_utils = require("core.utils")
local custom = require("core.custom")
local utils = require("core.utils")

return {
  {
    enabled = false,
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    lazy = false,
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
      { "<leader>bL", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
      { "<leader>bH", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
      { "<leader>bl", "<CMD>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "<leader>bh", "<CMD>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      options = {
        -- stylua: ignore
        close_command = function(n) require("mini.bufremove").delete(n, false) end,
        -- stylua: ignore
        right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = require("core.custom").icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd("BufAdd", {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },

  -- Preview code in floating window
  {
    "rmagatti/goto-preview",
    opts = {},
  },

  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      -- stylua: ignore
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
  },

  {
    "Aasim-A/scrollEOF.nvim",
    opts = {},
  },

  -- Show file name top right
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>r",
        function()
          vim.notify("refresh", vim.log.levels.INFO)
          require("incline").refresh()
        end,
        desc = "Refresh incline",
      },
    },
    opts = {
      debounce_threshold = 100,
      window = {
        padding = 0,
        margin = {
          horizontal = {
            left = 40,
            right = 0,
          },
          vertical = 1,
        },
        placement = {
          horizontal = "center",
          -- horizontal = "left",
          -- vertical = "bottom",
          vertical = "top",
        },
      },
      ignore = {
        -- floating_wins = false,
        unlisted_buffers = false,
        -- buftypes = function()
        --   return false
        -- end,
        -- wintypes = function()
        --   return false
        -- end,
        filetypes = { "dashboard" },
      },

      render = function(props)
        -- vim.g.count = (vim.g.count or 0) + 1
        -- print(vim.g.count)
        local colors = require("catppuccin.palettes.macchiato")

        local buf = props.buf
        local win = props.win
        local focused = props.focused
        local modified = vim.bo[props.buf].modified

        local function get_diagnostic_count(severity)
          return #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity:upper()] })
        end

        local function start_sec()
          local group = "DiagnosticSignOk"
          for _, severity in ipairs({ "Error", "Warn", "Hint", "Info" }) do
            if get_diagnostic_count(severity) > 0 then
              group = "DiagnosticSign" .. severity
              break
            end
          end
          return {
            { "▌ ", group = group },
          }
        end

        local function diagnostics_sec()
          local icons = require("core.custom").icons.diagnostics
          local errors = get_diagnostic_count("ERROR")
          local warnings = get_diagnostic_count("WARN")
          local error_text = (errors > 0 and icons.Error .. errors or "")
          local warnings_text = (warnings > 0 and icons.Warn .. warnings or "")
          -- text = vim.trim(text)

          local error_sec = { error_text, group = "DiagnosticSignError" }
          local warnings_sec = { warnings_text, group = "DiagnosticSignWarn" }
          local count = (errors > 0 and 1 or 0) + (warnings > 0 and 1 or 0)

          return {
            error_sec,
            { count > 1 and " " or "" },

            warnings_sec,
            { count > 0 and " " or "" },
          }
        end

        local function name_sec()
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end

          local file_icon, file_color = require("nvim-web-devicons").get_icon_color(filename)

          local text_style = ""
          if focused then
            text_style = (text_style ~= "" and (text_style .. ",") or "") .. "bold"
          end
          if modified then
            text_style = (text_style ~= "" and (text_style .. ",") or "") .. "italic"
          end
          text_style = text_style or "None"

          return {
            { file_icon, guifg = file_color },
            { " " },
            { filename, gui = text_style },
          }
        end

        local function modified_sec()
          local text = "   "
          if modified then
            text = " ● "
          end
          return {
            {
              text,
              guifg = colors.green,
            },
          }
        end

        local function end_sec()
          return {
            { " ▐", guifg = colors.green },
          }
        end

        local text_color = focused and colors.rosewater or colors.overlay2

        return {
          start_sec(),
          -- diagnostics_sec(),
          name_sec(),
          modified_sec(),
          -- end_sec(),
          guifg = text_color,
          guibg = colors.crust,
        }
      end,

      -- render = function(props)
      --   local function get_diagnostic_label(props)
      --     local icons = {
      --       Error = "",
      --       Warn = "",
      --       Info = "",
      --       Hint = "",
      --     }
      --
      --     local label = {}
      --     for severity, icon in pairs(icons) do
      --       local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
      --       if n > 0 then
      --         table.insert(label, { icon .. " " .. n .. " ", group = "DiagnosticSign" .. severity })
      --       end
      --     end
      --     return label
      --   end
      --
      --   local bufname = vim.api.nvim_buf_get_name(props.buf)
      --   local filename = vim.fn.fnamemodify(bufname, ":t")
      --   local diagnostics = get_diagnostic_label(props)
      --   local modified = vim.api.nvim_buf_get_option(props.buf, "modified") and "bold,italic" or "None"
      --   local filetype_icon, color = require("nvim-web-devicons").get_icon_color(filename)
      --   local colors = require("catppuccin.palettes.macchiato")
      --
      --   local buffer = {
      --     { filetype_icon, guifg = color },
      --     { " " },
      --     { filename, gui = modified },
      --   }
      --
      --   if #diagnostics > 0 then
      --     table.insert(diagnostics, { "| ", guifg = "grey" })
      --   end
      --   for _, buffer_ in ipairs(buffer) do
      --     table.insert(diagnostics, buffer_)
      --   end
      --   return diagnostics
      -- end,

      -- render = function(props)
      --   local helpers = require("incline.helpers")
      --   local devicons = require("nvim-web-devicons")
      --   local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      --   if filename == "" then
      --     filename = "[No Name]"
      --   end
      --   local ft_icon, ft_color = devicons.get_icon_color(filename)
      --   local modified = vim.bo[props.buf].modified
      --   return {
      --     ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
      --     " ",
      --     { filename, gui = modified and "bold,italic" or "bold" },
      --     " ",
      --     guibg = "#44406e",
      --   }
      -- end,

      -- render = function(props)
      --   local helpers = require("incline.helpers")
      --   local navic = require("nvim-navic")
      --   local devicons = require("nvim-web-devicons")
      --   local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      --   if filename == "" then
      --     filename = "[No Name]"
      --   end
      --   local ft_icon, ft_color = devicons.get_icon_color(filename)
      --   local modified = vim.bo[props.buf].modified
      --
      --   local create_navic_context = function()
      --     local context = {}
      --     local data = navic.get_data(props.buf) or {}
      --     for i, item in ipairs(data) do
      --       table.insert(context, {
      --         { item.icon, group = "NavicIcons" .. item.type },
      --         { item.name, group = "NavicText" },
      --       })
      --       if i < #data then
      --         context[#context + 1] = { " > ", group = "NavicSeparator" }
      --       end
      --     end
      --     return context
      --   end
      --
      --   local filename_section = {
      --     { filename, gui = modified and "bold,italic" or "bold" },
      --     " ",
      --     ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
      --   }
      --
      --   local res = {
      --     guibg = "#282642",
      --     " ",
      --   }
      --
      --   if props.focused then
      --     local context = create_navic_context()
      --     if #context > 0 then
      --       res[#res + 1] = context
      --       res[#res + 1] = " │ "
      --     end
      --   end
      --
      --   res[#res + 1] = filename_section
      --
      --   return res
      -- end,
    },
    init = function()
      local incline = require("incline")
      -- By default, incline will not fully redraw under an OptionSet event. Even though
      -- a buffer may change from hidden to unhidden and so it should start to get rendered.
      -- Therefore here we manually trigger complete refresh.
      vim.api.nvim_create_autocmd({ "OptionSet" }, {
        group = utils.augroup("incline"),
        -- pattern = "buflisted",
        callback = function(event)
          incline.refresh()
        end,
      })
    end,
  },

  {
    enabled = false,
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    keys = function()
      local command = require("neo-tree.command")
      return {
        -- Reveal the current file, or if in an unsaved file, the current working directory.
        -- Taken from help docs
        {
          "<leader>fs",
          function()
            local reveal_file = vim.fn.expand("%:p")
            if reveal_file == "" then
              reveal_file = vim.fn.getcwd()
            else
              local f = io.open(reveal_file, "r")
              if f then
                f.close(f)
              else
                reveal_file = vim.fn.getcwd()
              end
            end
            command.execute({
              reveal_file = reveal_file, -- path to file or folder to reveal
              reveal_force_cwd = true, -- change cwd without asking if needed
            })
          end,
          desc = "Reveal file",
        },
        {
          "<leader>fe",
          function()
            command.execute({ dir = vim.loop.cwd() })
          end,
          desc = "File explorer (cwd) (focus)",
        },
        {
          "<leader>fE",
          function()
            command.execute({ toggle = true, dir = vim.loop.cwd() })
          end,
          desc = "File explorer (cwd) (toggle)",
        },
        {
          "<leader>ge",
          function()
            command.execute({ source = "git_status" })
          end,
          desc = "Git explorer (focus)",
        },
        {
          "<leader>gE",
          function()
            command.execute({ source = "git_status", toggle = true })
          end,
          desc = "Git explorer (toggle)",
        },
        {
          "<leader>be",
          function()
            command.execute({ source = "buffers" })
          end,
          desc = "Buffer explorer (focus)",
        },
        {
          "<leader>bE",
          function()
            command.execute({ source = "buffers", toggle = true })
          end,
          desc = "Buffer explorer (toggle)",
        },
      }
    end,
    opts = {},
  },

  -- Peek line numbers
  {
    "nacro90/numb.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = function()
      local persistence = require("persistence")
      return {
        { "<leader>qs", persistence.load, desc = "Restore Session" },
        -- stylua: ignore
        { "<leader>ql", function() persistence.load({ last = true }) end, desc = "Restore Last Session" },
        { "<leader>qd", persistence.stop, desc = "Don't Save Current Session" },
      }
    end,
    opts = {
      options = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "terminal" },
    },
  },

  {
    "nmac427/guess-indent.nvim",
    opts = {},
  },

  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      -- vim.api.nvim_create_autocmd("FileType", {
      --   callback = function()
      --     local buffer = vim.api.nvim_get_current_buf()
      --     map("]]", "next", buffer)
      --     map("[[", "prev", buffer)
      --   end,
      -- })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },

  -- Point to lsp diagnostics
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    keys = {
      -- stylua: ignore
      { "<leader>lj", function() vim.notify("Toggled lsp lines") require("lsp_lines").toggle() end, desc = "Toggle diagnostics lines" },
    },
    init = function()
      -- Initially start with diagnostic disabled. Manually toggle it on when needed.
      vim.diagnostic.config({ virtual_lines = false })
    end,
    opts = {},
  },

  -- Show diagnostics in top right corner instead of inline
  {
    "dgagn/diagflow.nvim",
    event = "LspAttach",
    opts = {
      scope = "line",
    },
  },

  {
    enabled = false,
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "echasnovski/mini.files",
    keys = function()
      local files = require("mini.files")
      return {
        { "<leader>fm", files.open, desc = "Mini Files" },
        {
          "<leader>fM",
          function()
            files.open(vim.api.nvim_buf_get_name(0), false)
          end,
          desc = "Mini Files (buffer dir)",
        },
      }
    end,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowUpdate",
        callback = function(args)
          vim.wo[args.data.win_id].relativenumber = true
        end,
      })

      local files_set_cwd = function(path)
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        vim.fn.chdir(cur_directory)
        vim.notify("Set cwd to " .. cur_directory, vim.log.levels.INFO)
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          vim.keymap.set("n", "!", files_set_cwd, { buffer = args.data.buf_id, desc = "Set cwd" })
        end,
      })

      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          -- Make new window and set it as target
          local new_target_window
          vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
            vim.cmd(direction .. " split")
            new_target_window = vim.api.nvim_get_current_win()
          end)

          MiniFiles.set_target_window(new_target_window)
        end

        -- Adding `desc` will result into `show_help` entries
        local desc = "Split " .. direction
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          map_split(buf_id, "gs", "belowright horizontal")
          map_split(buf_id, "gv", "belowright vertical")
        end,
      })
    end,

    opts = {
      windows = {
        preview = true,
        width_preview = 50,
      },
    },
  },

  {
    "SmiteshP/nvim-navic",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
      {
        "nvim-lualine/lualine.nvim",
        -- opts = function(_, opts)
        --   opts.sections = opts.sections or {}
        --   opts.sections.lualine_c = opts.sections.lualine_c or {}
        --   table.insert(opts.sections.lualine_c, {
        --     -- function()
        --     --   return require("nvim-navic").get_location()
        --     -- end,
        --     -- cond = function()
        --     --   return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
        --     -- end,
        --     "navic",
        --   })
        -- end,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = core_utils.augroup("navic_lsp_attach"),
        callback = function(event)
          local navic = require("nvim-navic")
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, event.buf)
          end
        end,
      })
    end,
    opts = {
      icons = custom.icons.kinds,
      highlight = true,
    },
  },

  {
    "SmiteshP/nvim-navbuddy",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = core_utils.augroup("navbuddy_lsp_attach"),
        callback = function(event)
          local navbuddy = require("nvim-navbuddy")
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client.server_capabilities.documentSymbolProvider then
            return
          end

          navbuddy.attach(client, event.buf)
          require("which-key").register({
            ["<leader>ln"] = { navbuddy.open, "Navbuddy" },
          }, { buffer = event.buf })
        end,
      })
    end,
    opts = function()
      return {
        icons = custom.icons.kinds,
      }
    end,
  },

  {
    enabled = false,
    "artemave/workspace-diagnostics.nvim",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = core_utils.augroup("workspace-diagnostics_attach"),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          require("workspace-diagnostics").populate_workspace_diagnostics(client, event.buf)
        end,
      })
    end,
    opts = {},
  },
}
