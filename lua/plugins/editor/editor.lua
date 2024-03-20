local core_utils = require("core.utils")
local custom = require("core.custom")
local utils = require("core.utils")

return {
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
          vertical = "top",
        },
      },
      ignore = {
        unlisted_buffers = false,
        filetypes = { "dashboard" },
      },

      render = function(props)
        local colors = require("catppuccin.palettes.macchiato")

        local buf = props.buf
        local win = props.win
        local focused = props.focused
        local modified = vim.bo[props.buf].modified

        local function get_diagnostic_count(severity)
          return #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity:upper()] })
        end

        local function diagnostic_sec()
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

        local text_color = focused and colors.rosewater or colors.overlay2

        return {
          diagnostic_sec(),
          name_sec(),
          modified_sec(),
          guifg = text_color,
          guibg = colors.crust,
        }
      end,
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
